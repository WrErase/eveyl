namespace :api do
#  DC = Dalli::Client.new('127.0.0.1:11211', :expires_in => 6.hours)
  EAAL.cache = EAAL::Cache::FileCache.new

  desc "Sync with the API for Eve Data"
  task :data, [:id] => :environment do |t, args|
    keys = args[:id] ? [ApiKey.find(args[:id])] : ApiKey.active.all

    keys.each do |key|
      begin
        api = EveApi.new(key.key_id, key.vcode)
        api.sync_key_specific

        api.sync_api_general if key == ApiKey.admin_key
      rescue EveApi::InvalidApiKey => e
        Rails.logger.warn "Invalid API Key: #{key.key_id}"
      end
    end
  end
end
