module PriceHelper
  def format_price(price, round_large = true)
    return unless price.present?

    price = price.to_f

    if round_large && price > 10_000
      price = price.round(0)
    else
      if price.to_s =~ /\.0{1,}$/
        price = price.to_i.to_s
      else
        price = "%0.2f" % price
      end
    end

    number_with_delimiter(price)
  end
end
