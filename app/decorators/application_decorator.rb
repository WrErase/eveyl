class ApplicationDecorator < Draper::Decorator
  def mkt_value(user = nil)
    mkt = model.mkt_value(user)
    return '-' unless mkt

    h.format_price(mkt)
  end

  def mat_value(user = nil)
    mat = model.mat_value(user)
    return '-' unless mat

    h.format_price(mat)
  end

  def mat_perc(user = nil)
    perc = model.mat_perc(user)

    perc.present? ? perc : '-'
  end
end
