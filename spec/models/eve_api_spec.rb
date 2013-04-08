require 'spec_helper'

describe EveApi do
  let(:key) { FactoryGirl.build(:api_key) }
  before { ApiKey.stub(:find_by_key_id).and_return(key) }

  let(:api) { EveApi.new(1, 'abc') }
  let(:result) { double('result') }

  describe "running a request" do
    let(:params) { {stuff: 1} }
    let(:retval) { double('response',
                           request_time: Time.now,
                           cached_until: 1.hour.from_now) }

    context "cache expired" do
      before { ApiLog.should_receive(:cache_expired?)
                     .with('resource', 1)
                     .and_return(true) }

      before { api.eaal.should_receive(:scope=).with('scope') }

      context "success" do
        before { api.eaal.should_receive(:send)
                         .with('resource', params)
                         .and_return(retval) }
        before { api.should_receive(:log_api_sync)
                    .with('resource', 1, 'OK', retval) }

        specify { api.run_request('scope', 'resource', params).should == retval}
      end

      context "exception" do
        before { api.eaal.should_receive(:send)
                         .with('resource', params)
                         .and_raise(Exception) }
        before { api.should_receive(:log_api_sync)
                    .with('resource', 1, 'Exception', nil) }

        specify { api.run_request('scope', 'resource', params).should be_nil }
      end
    end

    context "cache not expired" do
      before { ApiLog.should_receive(:cache_expired?)
                     .with('resource', 1)
                     .and_return(false) }

      before { api.eaal.should_not_receive(:send) }
      specify { api.run_request('scope', 'resource', params).should be_nil }
    end
  end

  describe "logging the api transaction" do
    context "with a result" do
      let(:ts) { Time.parse("2013-01-01 00:00") }
      let(:cached_until) { Time.parse('2013-01-01 01:00') }

      let(:result) { OpenStruct.new(request_time: ts,
                                    cached_until: cached_until) }

      before { api.log_api_sync('resource', 1, 'OK', result) }
      specify { ApiLog.count.should == 1 }
      specify { ApiLog.first.resource_name.should == 'resource' }
      specify { ApiLog.first.resource_id.should == 1 }
      specify { ApiLog.first.status.should == 'OK' }
      specify { ApiLog.first.ts.should == ts }
      specify { ApiLog.first.key_id.should == api.key_id }
      specify { ApiLog.first.cached_until.should == cached_until }
    end

    context "without a result" do
      before { api.log_api_sync('resource', 1, 'Exception', nil) }
      specify { ApiLog.count.should == 1 }
      specify { ApiLog.first.resource_name.should == 'resource' }
      specify { ApiLog.first.resource_id.should == 1 }
      specify { ApiLog.first.status.should == 'Exception' }
      specify { ApiLog.first.ts.should_not be_nil }
      specify { ApiLog.first.key_id.should == api.key_id }
      specify { ApiLog.first.cached_until.should be_nil }
    end
  end

  describe "syncing key info" do
    let(:char) { double('character', characterID: 1,
                                     characterName: 'name',
                                     corporationID: 2,
                                     corporationName: 'cname') }
    let(:result_key) { double('key', characters: [char]) }
    let(:result) { double('result', key: result_key) }
    let(:corp) { FactoryGirl.build(:corporation) }

    before { api.should_receive(:run_request)
                .with('account', 'APIKeyInfo')
                .and_return(result) }

    before { api.key.should_receive(:update_from_api)
                    .with(result) }

    context "success" do
      before { Corporation
                  .should_receive(:find_or_create_by_corporation_id)
                  .with(2)
                  .and_return(corp) }

      before { api.sync_key_info }

      specify { Character.count.should == 1 }
      specify { Character.first.name.should == 'name' }
      specify { Character.first.corporation_id.should == 2 }
      specify { Character.first.key_id.should == key.key_id }
      specify { api.character_ids.should == [1] }
    end
  end

  describe "syncing skill in training" do
    before { api.stub(:character_ids).and_return([1]) }
    before { api.should_receive(:run_request)
                .with('char', 'SkillInTraining', {'characterID' => 1})
                .and_return(result) }
    before { SkillInTraining.should_receive(:update_from_api)
                            .with(1, result) }

    specify { api.sync_skill_in_training }

  end

  describe "syncing stations" do
    let(:corp) { FactoryGirl.build(:corporation) }
    let(:outpost) { double('outposts',
                            corporationID: 123,
                            corporationName: 'corp') }
    let(:result) { double('result', outposts: [outpost]) }

    before { api.stub(:character_ids).and_return([1]) }
    before { api.should_receive(:run_request)
                .with('eve', 'ConquerableStationList')
                .and_return(result) }
    before { Station.should_receive(:update_from_api).with(outpost) }
    before { Corporation
               .should_receive(:find_or_create_by_corporation_id)
               .with(123)
               .and_return(corp) }

    specify { api.sync_stations }
  end

  describe "syncing corporations" do
    context "without delay" do
      before { api.should_receive(:sync_corporation).with(12) }
      specify { api.sync_corporations([12]) }
    end

    context "with delay" do
      let(:ids) { 100.downto(1).to_a }
      before { api.should_receive(:add_delay).with(0.15).exactly(100).times }
      before { api.should_receive(:sync_corporation).exactly(100).times }

      specify { api.sync_corporations(ids) }
    end
  end

  describe "getting the kills for a system" do
    let(:time_str) { '2013-01-01 12:00:00' }
    let(:data_time) { Time.parse(time_str).utc }

    let(:kills_system) { double('solar_system',
                                   solarSystemID: '12',
                                   shipKills: 3,
                                   podKills: 4,
                                   factionKills: 5) }

    let(:kills_result) { double('result', dataTime: time_str,
                                          solarSystems: [kills_system]) }

    before { api.should_receive(:ts_to_utc)
                .with(time_str)
                .and_return(data_time) }

    before { api.should_receive(:run_request)
                .with('map', 'Kills')
                .and_return(kills_result) }

    let(:result) { {datatime: data_time,
                    12=>{ship_kills: 3, faction_kills: 5, pod_kills: 4}} }
    specify { api.get_kills.should == result }
  end

  describe "getting the jumps for a system" do
    let(:time_str) { '2013-01-01 12:00:00' }
    let(:jumps_system) { double('solar_system',
                                  solarSystemID: '12',
                                  shipJumps: 6) }

    let(:jumps_result) { double('result', dataTime: time_str,
                                          solarSystems: [jumps_system]) }

    before { api.should_receive(:run_request)
                .with('map', 'Jumps')
                .and_return(jumps_result) }

    let(:result) { {12 => 6} }
    specify { api.get_jumps.should == result }
  end

  describe "syncing system stats" do
    let(:data_time) { Time.parse('2013-01-01') }

    let(:kill_result) { { datatime: data_time,
                          12=>{ship_kills: 3,
                               faction_kills: 5,
                               pod_kills: 4}} }
    let(:jump_result) { {12 => 6} }

    before { api.should_receive(:get_jumps).and_return(jump_result) }
    before { api.should_receive(:get_kills).and_return(kill_result) }

    let(:result_set) { {12=>{ship_kills: 3, faction_kills: 5,
                             pod_kills: 4, ship_jumps: 6}} }

    before { SolarSystemStat.should_receive(:update_from_api)
                            .with(data_time, result_set) }

    specify { api.sync_system_stats }
  end
end
