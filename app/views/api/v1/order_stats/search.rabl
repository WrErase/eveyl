collection @stats, :root => 'order_stats', :object_root => false

node(:type_id) { @type_id }
node(:generated_at) { Time.now.utc }

# All regions, stats
node(:regions) do |r|
  @stats.regions.map { |h| { :region_id => h.region_id, :name => h.name, :order_stats => h.order_stats } }
end

#cache [:order_histories, params[:type_id], params[:region_id]], expires_in: 30.minutes
