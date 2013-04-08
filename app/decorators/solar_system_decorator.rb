class SolarSystemDecorator < ApplicationDecorator
  delegate_all

  def stations
    StationDecorator.decorate_collection(source.stations)
  end

  def owner
    # TODO - Link to alliances, when those are added
    if faction
      faction_name
    elsif alliance
      alliance_name
    else
      '-'
    end
  end
end
