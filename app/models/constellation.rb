class Constellation < ActiveRecord::Base
  has_many :solar_systems
  has_many :stations

  belongs_to :region

  validates_presence_of :name
end
