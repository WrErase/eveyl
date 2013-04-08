class Corporation < ActiveRecord::Base
  belongs_to :alliance

  has_many :sovereignties

  has_many :solar_systems, :through => :sovereignties

  has_many :stations

  delegate :name, :to => :alliance, :prefix => true, :allow_nil => true

  validates :name, presence: true

  def self.update_from_api(result)
    return unless result

    corp = Corporation.find_or_initialize_by_corporation_id(result.corporationID)
    corp.update_attributes({name: result.corporationName,
                            ticker: result.ticker,
                            ceo_id: result.ceoID,
                            ceo_name: result.ceoName,
                            station_id: result.stationID,
                            description: result.description,
                            url: result.url,
                            alliance_id: result.allianceID,
                            tax_rate: result.taxRate,
                            member_count: result.memberCount,
                            shares: result.shares,
                            graphic_id: result.logo.graphicID,
                            cached_until: result.cached_until}, without_protection: true)
  end
end
