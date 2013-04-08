class TypeDecorator < ApplicationDecorator
  delegate_all

  def days_string(val)
    days = (val / 86400.0).floor
    hours = (val % 86400.0 / 3600.0).floor
    minutes = (val % 86400 % 3600.0 / 60).floor

    str = []
    str << "#{days} Days" if days > 0
    str << "#{hours} Hours" if hours > 0
    str << "#{minutes} Minutes" if minutes > 0

    str.join(', ')
  end

  def market_group_chain
    return '' unless source.market_group

    source.market_group.group_chain.map do |mg|
      h.link_to mg.name, h.market_group_path(mg.id)
    end.join(' / ').html_safe
  end

  def production_time
    days_string(source.production_time)
  end

  def research_material_time
    days_string(source.research_material_time)
  end

  def research_productivity_time
    days_string(source.research_productivity_time)
  end

  def research_tech_time
    days_string(source.research_tech_time)
  end

  def research_copy_time
    days_string(source.research_copy_time)
  end
end
