class CorporationDecorator < ApplicationDecorator
  delegate_all

  def name_with_ticker
    str = source.name

    if source.ticker
      str += " (#{source.ticker})"
    end

    str
  end
end
