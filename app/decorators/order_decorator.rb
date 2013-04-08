class OrderDecorator < ApplicationDecorator
  delegate_all

  def station_name_with_security
    "#{model.station_name} (#{model.security.round(2)})"
  end
end
