class Alliance < ActiveRecord::Base
  has_many :corporations

  has_many :sovereignties

  has_many :solar_systems, :through => :sovereignties

  has_many :stations

  def self.update_from_api(result)
    a = self.find_or_initialize_by_alliance_id(result.allianceID)
    a.update_attributes({name: result.name,
                         short_name: result.shortName,
                         executor_corp_id: result.executorCorpID,
                         member_count: result.memberCount,
                         start_date: result.startDate}, without_protection: true)

  end
end
