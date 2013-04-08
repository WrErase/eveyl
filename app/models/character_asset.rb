class UnknownFormat < StandardError; end

class CharacterAsset < ActiveRecord::Base
  self.primary_key = :item_id

  belongs_to :character
  belongs_to :type

  belongs_to :solar_system
  belongs_to :station

  has_one :region, :through => :solar_system

  belongs_to :container, :class_name => 'CharacterAsset',
                         :primary_key => :item_id,
                         :foreign_key => :parent_id

  has_many :children, :class_name => 'CharacterAsset',
                      :primary_key => :item_id,
                      :foreign_key => :parent_id

  has_one :meta_group, :through => :type

  delegate :name, :to => :type, :prefix => true, :allow_nil => true

  delegate :name, :to => :region, :prefix => true
  delegate :name, :to => :solar_system, :prefix => true
  delegate :name, :to => :station, :prefix => true, :allow_nil => true
  delegate :name, :to => :meta_group, :prefix => true, :allow_nil => true
  delegate :name, :to => :character, :prefix => true, :allow_nil => true

  delegate :category_name, :to => :type
  delegate :tech_level, :to => :type
  delegate :meta_level, :to => :type
  delegate :materials, :to => :type

  delegate :mkt_value, :to => :type
  delegate :mat_value, :to => :type
  delegate :mat_perc, :to => :type

  validates :character_id, :presence => true, :numericality => true
  validates :type_id, :presence => true, :numericality => true
  validates :item_id, :presence => true, :numericality => true
  validates :solar_system_id, :presence => true, :numericality => true
  validates :quantity, :presence => true, :numericality => true

  validates :parent_id, :numericality => true, :allow_nil => true
  validates :station_id, :numericality => true, :allow_nil => true

  def self.create_from_api(char_id, assets)
    if assets.class.to_s =~ /CharAssetListRowset/
      create_from_eaal(char_id, assets)
    else
      raise UnknownFormat, assets.class.to_s
    end
  end

  def self.flush_for_character(id)
    return unless id

    CharacterAsset.where(character_id: id).destroy_all
  end

  def self.assets_for_characters(ids)
    query = self.joins(:type)
                .includes(:type, :character, :station, {:type => :category}, :children)

    query = query.where("character_assets.character_id in (?)", ids)
  end

  def has_parent?
    !!(self.parent_id)
  end

  private

  def self.get_location(asset, parent)
    if asset.locationID
      station_id = asset.locationID if station_id?(asset.locationID)
      solar_system_id = lookup_system(asset.locationID)
    else
      station_id = parent.station_id
      solar_system_id = parent.solar_system_id
    end

    OpenStruct.new(station_id: station_id,
                   solar_system_id: solar_system_id)
  end

  def self.create_from_eaal(char_id, asset, parent = nil)
    loc = get_location(asset, parent)

    ca = CharacterAsset.create({character_id: char_id,
                                parent_id: parent.try(:item_id),
                                item_id: asset.itemID,
                                solar_system_id: loc.solar_system_id,
                                station_id: loc.station_id,
                                type_id: asset.typeID,
                                flag: asset.flag,
                                quantity: asset.quantity.to_i,
                                singleton: asset.singleton,
                                raw_quantity: asset.rawQuantity},
                               :without_protection => true)
    if asset.contents
      asset.contents.each { |sub| create_from_eaal(char_id, sub, ca) }
    end
  end

  def self.lookup_system(location_id)
    if station_id?(location_id)
      station = Station.find_by_station_id(location_id)
      solar_system_id = station.solar_system_id
    else
      solar_system_id = location_id
    end

    solar_system_id
  end

  def self.station_id?(id)
    id.to_i.between?(60000000, 61000000)
  end
end
