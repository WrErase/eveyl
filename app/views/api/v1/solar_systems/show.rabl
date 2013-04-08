object @solar_system

attributes :solar_system_id, :name, :security, :constellation_id, :constellation_name, :region_id, :region_name

child :stats_48h => :solar_system_stats do
  attributes :ts, :ship_kills, :pod_kills, :faction_kills, :ship_jumps
end

node :links do |s|
  {
   'region' => {href: api_region_path(s.region_id)},
  }
end
