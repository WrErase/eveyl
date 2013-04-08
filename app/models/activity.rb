class Activity < ActiveRecord::Base
  validates :activity_id, presence: true
  validates :name, presence: true
end
