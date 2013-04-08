require 'spork'

def spork?
  defined?(Spork) && Spork.using_spork?
end

def simplecov?
  defined?(SimpleCov) && SimpleCov.using_simplecov?
end

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'

  if spork?
    # This will not work correctly in apps using Devise
    require 'rails/application'
    Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  else
    require 'simplecov'
    SimpleCov.start 'rails' do
      add_group "Decorators", "app/decorators"
    end
  end

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each {|f| require f}

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
#  require 'headless'

#  Capybara.default_host = 'http://test.com'

  RSpec.configure do |config|
    config.include Devise::TestHelpers, :type => :controller

    config.include Warden::Test::Helpers
    Warden.test_mode!

    config.mock_with :rspec

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)

#      headless = Headless.new
#      headless.start
    end

    config.before(:all) do
      DeferredGarbageCollection.start
    end

    config.before(:each) do
      DeferredGarbageCollection.reconsider
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
#      Capybara.use_default_driver
    end

    config.after(:suite) do
  #    headless.destroy
    end
  end
end

Spork.each_run do
  require 'factory_girl_rails'

#  ActiveSupport::Dependencies.clear if spork?

#  Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

  Warden.test_reset!

  FactoryGirl.factories.clear
  Dir.glob("./spec/factories/*.rb").each { |file| load "#{file}" }
end
