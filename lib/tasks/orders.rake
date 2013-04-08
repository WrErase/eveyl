namespace :orders do
  desc "Handle Order Stats"

  desc "Build Order Stats"
  task :stats => :environment do
    OrderStat.build_all
  end
end
