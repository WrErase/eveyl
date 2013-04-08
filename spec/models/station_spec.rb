require 'spec_helper.rb'

describe OrderStat do
  describe "update_from_api" do
    let(:system) { FactoryGirl.create(:solar_system) }

    let(:station) {
      FactoryGirl.build(:station, region_id: system.region_id,
                                  constellation_id: system.constellation_id,
                                  solar_system_id: system.solar_system_id)
    }

    let(:result) { OpenStruct.new(stationID: station.station_id,
                                  name: station.name,
                                  stationTypeID: station.station_type_id,
                                  solarSystemID: system.solar_system_id,
                                  corporationID: station.corporation_id) }

    before { Station.update_from_api(result) }

    specify { Station.count.should == 1 }
    specify { Station.first.should == station }
  end
end
