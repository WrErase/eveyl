class SovereigntyHistory < ActiveRecord::Base
  belongs_to :corporation
  belongs_to :alliance
  belongs_to :solar_system

  delegate :name, :to => :corporation, :prefix => true, :allow_nil => true
  delegate :name, :to => :solar_system, :prefix => true
  delegate :name, :to => :alliance, :prefix => true, :allow_nil => true
end
