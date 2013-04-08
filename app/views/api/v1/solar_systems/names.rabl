collection @names, :object_root => false

attributes :name, :solar_system_id

node :links do |s|
  {'self' => {href: api_solar_system_path(s)},
  }
end

cache [:regions, :names]
