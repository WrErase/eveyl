class EveApi
  attr_reader :key_id, :vcode, :eaal, :key, :character_ids

  def initialize(key_id, vcode, cache = :file)
    @key_id = key_id
    @vcode  = vcode

    EAAL.cache = EAAL::Cache::FileCache.new if cache == :file

    @eaal = EAAL::API.new(key_id, vcode)

    @key = get_key

    @character_ids = []
  end

  def add_delay(seconds)
    return unless seconds
    sleep seconds
  end

  def ts_to_utc(ts)
    ActiveSupport::TimeZone.new('UTC').parse(ts)
  end

  def log_api_sync(resource, id, status, result)
    cached_until = result.try(:cached_until)
    result_ts    = result.try(:request_time)

    return if ApiLog.exists?(resource, id, cached_until)

    ApiLog.create({resource_name: resource,
                   resource_id: id,
                   key_id: key_id,
                   ts: result_ts || Time.now.gmtime,
                   status: status,
                   cached_until: cached_until},
                  :without_protection => true)
  end

  def get_key
    key = ApiKey.find_by_key_id(key_id)
    raise UnknownApiKey unless key

    key
  end

  def run_request(scope, resource, params = nil)
    id = params.first.last if params

    return unless ApiLog.cache_expired?(resource, id)

    eaal.scope = scope

    status = 'OK'
    begin
      result = eaal.send(resource, params)
    rescue Exception => e
      Rails.logger.debug "#{e.class}\n#{e.backtrace}"
      status = e.class.to_s
    end

    log_api_sync(resource, id, status, result)

    result
  end

  def sync_key_specific
    sync_key_info
    sync_account_status
    sync_characters
    sync_character_corps
    sync_character_assets
    sync_skill_in_training
  end

  def sync_api_general
    sync_stations
    sync_sov
    sync_alliances
    sync_system_stats
  end

  def self.get_key_info(key)
    eaal = EAAL::API.new(key.key_id, key.vcode)
    eaal.scope = 'account'

    eaal.send('APIKeyInfo')
  end

  def init_corp(id, name)
    return unless id

    corp = Corporation.find_or_create_by_corporation_id(id)
    corp.name = name

    corp
  end

  def sync_key_info
    result = run_request('account', 'APIKeyInfo')
    raise InvalidApiKey unless result

    result.key.characters.each do |char|
      build_character_from_result(char)

      @character_ids << char.characterID.to_i
      init_corp(char.corporationID, char.corporationName)
    end

    key.update_from_api(result) if result
  end

  def sync_account_status
    result = run_request('account', 'AccountStatus')
    return unless result

    Account.update_from_api(@key_id, result) if result
  end

  def character_ids
    return @character_ids unless @character_ids.empty?

    result = run_request('account', 'Characters')
    return [] unless result

    @character_ids = result.characters.map { |c| c.characterID.to_i } if result
  end

  def sync_characters
    character_ids.each do |id|
      result = run_request('char', 'CharacterSheet', {"characterID" => id})
      next unless result

      importer = CharacterSheetImporter.new(key: @key, sheet: result)
      importer.load_skills
      importer.load_character
    end
  end

  def sync_character_corps
    character_ids.each do |id|
      char = Character.find(id)
      sync_corporation(char.corporation_id)
    end
  end

  def sync_character_assets(flush = true)
    character_ids.each do |id|
      result = run_request('char', 'AssetList', {"characterID" => id})
      return unless result

      ActiveRecord::Base.transaction do
        CharacterAsset.flush_for_character(id) if flush
        result.assets.each do |asset|
          CharacterAsset.create_from_api(id, asset)
        end
      end
    end
  end

  def sync_skill_in_training
    character_ids.each do |id|
      result = run_request('char', 'SkillInTraining', {"characterID" => id})
      return unless result

      SkillInTraining.update_from_api(id, result)
    end
  end

  def sync_stations
    result = run_request('eve', 'ConquerableStationList')
    return unless result

    ActiveRecord::Base.transaction do
      result.outposts.each do |r|
        Station.update_from_api(r)
        corp = init_corp(r.corporationID, r.corporationName)
        corp.save
      end
    end
  end

  def sync_alliances
    result = run_request('eve', 'AllianceList')
    return unless result

    ActiveRecord::Base.transaction do
      result.alliances.each { |a| Alliance.update_from_api(a) }
    end
  end

  def sync_corporations(corp_ids)
    wait_time = 0.15 if corp_ids.length > 25
    ActiveRecord::Base.transaction do
      corp_ids.each do |id|
        sync_corporation(id)
        add_delay wait_time if wait_time
      end
    end
  end

  def sync_corporation(corp_id)
    result = run_request('corp', 'CorporationSheet', {"corporationID" => corp_id.to_s})
    return unless result

    Corporation.update_from_api(result)
  end

  def sync_missing_corporations
    ids = Corporation.where(:ticker => nil).pluck(:corporation_id)

    sync_corporations(ids)
  end

  def sync_sov
    result = run_request('map', 'Sovereignty')
    return unless result

    ActiveRecord::Base.transaction do
      data_time = self.ts_to_utc(result.dataTime)
      result.solarSystems.each do |s|
        Sovereignty.update_from_api(s, data_time)
      end
    end
  end

  def get_kills
    kills = run_request('map', 'Kills')
    return unless kills

    datatime = self.ts_to_utc(kills.dataTime)

    result = {datatime: datatime}
    kills.solarSystems.each do |k|
      system_id = k.solarSystemID.to_i

      result[system_id] = {ship_kills: k.shipKills.to_i,
                           faction_kills: k.factionKills.to_i,
                           pod_kills: k.podKills.to_i}
    end

    result
  end

  def get_jumps
    jumps = run_request('map', 'Jumps')
    return unless jumps

    datatime = self.ts_to_utc(jumps.dataTime)

    result = {datatime: datatime}
    jumps.solarSystems.inject({}) do |hsh, j|
      system_id = j.solarSystemID.to_i

      hsh[system_id] = j.shipJumps.to_i

      hsh
    end
  end

  def sync_system_stats
    result = get_kills || {}

    jumps = get_jumps
    return unless jumps

    jumps.each do |k,v|
      if result[k]
        result[k].merge!( {ship_jumps: v} )
      else
        result[k] = {ship_jumps: v}
      end
    end

    datatime = result.delete(:datatime)

    SolarSystemStat.update_from_api(datatime, result)
  end

  private

  def build_character_from_result(char)
    new = Character.find_or_initialize_by_character_id(char.characterID)
    new.name = char.characterName
    new.corporation_id = char.corporationID
    new.api_key = key
    new.save!
  end

  class UnknownApiKey < Exception; end
  class InvalidApiKey < Exception; end
end
