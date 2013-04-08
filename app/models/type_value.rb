# Value for a Type/Region/Stat combination
class TypeValue < ActiveRecord::Base
  belongs_to :type

  validates :type_id, presence: true
  validates :region_id, presence: true

  validates :value, presence: true

  def self.find_by_region_stat(type_id, region_id = '10000002', stat = 'mid_buy_sell')
    where(type_id: type_id, region_id: region_id, stat: stat).last
  end
end
