object @type

extends "api/v1/types/base"

attributes :name, :description

attribute :tech_level, :if => lambda { |m| m.tech_level.present? }
attribute :meta_level, :if => lambda { |m| m.meta_level.present? }

node :links do |t|
  {
   'order_histories' => {href: api_type_order_histories_path(t)},
  }
end

#cache [:types, params[:type_id]], expires_in: 30.minutes
