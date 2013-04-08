collection @names, :object_root => false

attributes :name, :type_id

node :links do |t|
  {'self' => {href: api_type_path(t)},
  }
end

#cache [:types, :names, params[:q]]
