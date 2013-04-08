namespace :emdr do
  desc "Monitor"
  task :monitor => :environment do
    %w(INT TERM KILL).each { |signal| trap(signal)  { exit } }

    begin
      ActiveRecord::Base.logger = Rails.logger.clone
      ActiveRecord::Base.logger.level = Logger::INFO

      logger = Logger.new(Rails.root.to_s + '/log/emdr.log')
      logger.level = Logger::WARN

      e = Emdr.new(logger: logger)

      e.monitor
    end
  end
end

