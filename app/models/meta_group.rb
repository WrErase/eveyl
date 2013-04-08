class MetaGroup < ActiveRecord::Base
  belongs_to :meta_type, :foreign_key => :meta_group_id
end
