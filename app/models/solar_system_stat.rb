class SolarSystemStat < ActiveRecord::Base
  belongs_to :solar_system

  scope :last_day, where("ts >= ?", 1.day.ago).order("ts desc")
  scope :last_48h, where("ts >= ?", 48.hours.ago).order("ts desc")
  scope :last_72h, where("ts >= ?", 72.hours.ago).order("ts desc")

  validates :solar_system_id, :presence => true, :numericality => true

  validates :ship_kills, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :pod_kills, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :faction_kills, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :ship_jumps, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true

  def self.exists?(ts, id)
    !!self.where(ts: ts, solar_system_id: id).first
  end

  def self.update_from_api(ts, result)
    ActiveRecord::Base.transaction do
      SolarSystem.ids.each do |id|
        next if exists?(ts, id)

        data = result[id] || {}
        data.merge!({solar_system_id: id, ts: ts})

        create(data, :without_protection => true)
      end
    end
  end

end
