object @region

attributes :region_id, :name, :faction_id, :has_hub

child :solar_systems do
  attributes :solar_system_id, :name

  node :links do |s|
    {
     'self' => {href: api_solar_system_path(s)},
     }
  end
end

node :links do |r|
{
 'self' => {href: api_region_path(r)},
 }
end

cache @region
