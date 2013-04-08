object @pc

child :collection => :regions do
  attributes :region_id, :name

  node :links do |r|
    {'self' => {href: api_region_path(r)},
     'solar_systems' => {href: api_region_solar_systems_path(r)},
    }
  end
end

node :pagination do |s|
  s.to_hash
end

