class Group < ActiveRecord::Base
  has_many :types

  belongs_to :category
end
