object @pc

child :collection => :solar_systems do
  attributes :solar_system_id, :name, :security, :constellation_id, :constellation_name, :region_id, :region_name

  node :links do |s|
    {'self' => {href: api_solar_system_path(s)},
     'region' => {href: api_region_path(s.region_id)},
    }
  end
end

node :pagination do |s|
  s.to_hash
end


