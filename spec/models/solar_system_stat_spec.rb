require 'spec_helper'

describe SolarSystemStat do
  let(:ts) { Time.now }

  describe "stat exists" do
    let!(:stat) { FactoryGirl.create(:solar_system_stat) }

    specify { SolarSystemStat.exists?(stat.ts, stat.solar_system_id)
                             .should be_true }
    specify { SolarSystemStat.exists?(stat.ts, stat.id - 1)
                             .should be_false }
  end

  describe "updating from the api" do
    let(:ids) { [1,2,3] }
    let(:result) { {1 => {ship_kills: 1},
                    3 => {ship_kills: 3}} }
    let(:create1) { {ship_kills: 1, solar_system_id: 1, ts: ts} }
    let(:create2) { {solar_system_id: 2, ts: ts} }
    let(:create3) { {ship_kills: 3, solar_system_id: 3, ts: ts} }

    before { SolarSystem.stub(:ids).and_return(ids) }
    before { SolarSystemStat.should_receive(:exists?)
                        .with(ts, 1).and_return(false) }
    before { SolarSystemStat.should_receive(:exists?)
                        .with(ts, 2).and_return(false) }
    before { SolarSystemStat.should_receive(:exists?)
                        .with(ts, 3).and_return(true) }

    before { SolarSystemStat.should_receive(:create)
                            .with(create1, without_protection: true) }
    before { SolarSystemStat.should_receive(:create)
                            .with(create2, without_protection: true) }
    before { SolarSystemStat.should_not_receive(:create)
                            .with(create3, without_protection: true) }

    specify { SolarSystemStat.update_from_api(ts, result) }
  end
end
