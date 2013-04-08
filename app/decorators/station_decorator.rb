class StationDecorator < ApplicationDecorator
  delegate_all

  def reprocess_eff_perc
    return '-' unless reprocess_eff

    h.number_to_percentage(reprocess_eff * 100, precision: 0)
  end

  def reprocess_take_perc
    return '-' unless reprocess_eff

    h.number_to_percentage(reprocess_take * 100, precision: 0)
  end
end
