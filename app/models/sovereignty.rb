class Sovereignty < ActiveRecord::Base
  belongs_to :corporation
  belongs_to :alliance
  belongs_to :solar_system
  belongs_to :faction

  before_save :create_history

  delegate :name, :to => :corporation, :prefix => true, :allow_nil => true
  delegate :name, :to => :solar_system, :prefix => true
  delegate :name, :to => :alliance, :prefix => true, :allow_nil => true
  delegate :name, :to => :faction, :prefix => true, :allow_nil => true

  def self.update_from_api(result, data_time)
    sov = self.find_or_initialize_by_solar_system_id(result.solarSystemID)
    sov.update_attributes({alliance_id: result.allianceID,
                           faction_id: result.factionID,
                           corporation_id: result.corporationID,
                           data_time: data_time}, without_protection: true)
  end

  def owner_changed?
    return false if self.new_record?

    !(self.changes.keys & ['corporation_id', 'alliance_id']).empty?
  end

  def create_history
    return unless owner_changed?

    old = SovereigntyHistory.where(data_time: self.data_time,
                                   solar_system_id: self.solar_system_id_was).first
    return if old

    SovereigntyHistory.create({solar_system_id: self.solar_system_id_was,
                               alliance_id: self.alliance_id_was,
                               faction_id: self.faction_id_was,
                               corporation_id: self.corporation_id_was,
                               data_time: self.data_time}, without_protection: true)
  end
end
