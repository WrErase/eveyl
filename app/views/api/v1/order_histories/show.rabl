object @histories

node(:type_id) { @histories.type_id }
node(:generated_at) { Time.now.utc }

node(:regions) do |r|
  @histories.regions.map { |h| { :region_id => h.region_id, :name => h.name, :order_histories => h.order_histories } }
end

#cache [:order_histories, params[:type_id], params[:region_id]], expires_in: 30.minutes
