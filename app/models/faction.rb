class Faction < ActiveRecord::Base
  belongs_to :solar_system
  belongs_to :corporation
end
