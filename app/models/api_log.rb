class ApiLog < ActiveRecord::Base
  scope :recent, where("ts >= ?", 2.days.ago)

  validates_presence_of :resource_name, :ts

  def self.cache_expired?(resource_name, id)
    !(ApiLog.where(resource_name: resource_name, resource_id: id)
            .where("cached_until > ?", Time.now).first)

  end

  def self.exists?(resource_name, id, cached_until)
    return false unless cached_until

    !!(ApiLog.where(resource_name: resource_name,
                    resource_id: id, cached_until: cached_until).first)
  end
end
