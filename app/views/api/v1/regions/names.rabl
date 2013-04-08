collection @names, :object_root => false

attributes :name, :region_id

node :links do |s|
  {'self' => {href: api_region_path(s)},
  }
end

cache [:regions, :names]
