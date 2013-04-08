class UserProfile < ActiveRecord::Base
  belongs_to :user

  validates :default_stat,
               presence: true,
               inclusion: {in: OrderStat.value_stats.map { |s| s.to_s },
                           message: 'is not a valid stat'}

  validates :default_region,
               presence: true,
               numericality: { only_integer: true,
                               greater_than_or_equal_to: 10000000,
                               less_than_or_equal_to: 20000000,
                               message: 'is not a valid region'}
end
