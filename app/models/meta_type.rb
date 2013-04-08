class MetaType < ActiveRecord::Base
  has_one :meta_group, foreign_key: :meta_group_id,
                       primary_key: :meta_group_id

  belongs_to :type, foreign_key: :type_id

  delegate :name, to: :meta_group, prefix: true
end
