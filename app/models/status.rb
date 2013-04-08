class Status
  def self.stats
    OpenStruct.new(orders_total: Order.count,
                   orders_active: Order.active.count,
                   orders_expired: Order.expired.count,
                   orders_hour: Order.last_hour.count,
                   orders_day: Order.last_day.count,
                   histories_total: OrderHistory.count,
                   histories_day: OrderHistory.last_day.count,
                   system_stats: SolarSystemStat.count,
                   system_stats_day: SolarSystemStat.last_day.count,
                   alliances: Alliance.count,
                   corporations: Corporation.count,
                   stations: Station.count,
                   player_stations: Station.player.count,
                   users: User.count,
                   characters: Character.count,
                   )
  end
end
