require 'spec_helper.rb'

describe CharacterAsset do
  let(:character_id) { 1 }
  let(:location_id) { 61000000 }
  let(:system_id) { 30000001 }
  let(:station) { OpenStruct.new(solar_system_id: system_id) }

  describe "create_from_api" do
    context "eaal format" do
      let(:result) { double('asset') }
      before { result.stub(:class).and_return('CharAssetListRowsetAssetsRow') }

      before { CharacterAsset.should_receive(:create_from_eaal).with(character_id, result) }

      specify { CharacterAsset.create_from_api(character_id, result).should be_nil }
    end

    context "unknown format" do
      let(:result) { double('asset', name: 'Wrong') }

      before { CharacterAsset.should_not_receive(:create_from_eaal) }

      specify { lambda { CharacterAsset.create_from_api(character_id, result)}.should raise_error(UnknownFormat) }
    end
  end

  describe "create_from_eaal" do
    let(:asset) { FactoryGirl.build(:character_asset) }
    let(:contents) { nil }
    let(:asset_data) { OpenStruct.new(itemID: asset.item_id, typeID: asset.type_id,
                                      locationID: location_id,
                                      flag: asset.flag, quantity: asset.quantity,
                                      singleton: asset.singleton,
                                      rawQuantity: asset.raw_quantity,
                                      contents: contents) }

    context "asset with no children" do

      before { Station.should_receive(:find_by_station_id).with(location_id).and_return(station) }
      before { CharacterAsset.create_from_eaal(character_id, asset_data) }

      specify { CharacterAsset.count.should == 1 }
      specify { CharacterAsset.first.should == asset }
    end

    context "asset with children" do
      let(:child_id) { 1234 }
      let(:child_asset) { OpenStruct.new(itemID: child_id, typeID: 34,
                                         quantity: 1, flag: 1, singleton: '0') }
      let(:contents) { [child_asset] }

      before { Station.should_receive(:find_by_station_id).with(location_id).and_return(station) }
      before { CharacterAsset.create_from_eaal(character_id, asset_data) }

      specify { CharacterAsset.count.should == 2 }
      specify { CharacterAsset.first.should == asset }
      specify { CharacterAsset.last.item_id.should == child_id }
      specify { CharacterAsset.last.type_id.should == 34 }
      specify { CharacterAsset.last.parent_id.should == asset.id }
      specify { CharacterAsset.last.station_id.should == location_id }
      specify { CharacterAsset.last.solar_system_id.should == system_id }
    end
  end

  describe "flush_for_character" do
    before { FactoryGirl.create(:character_asset, character_id: character_id) }
    before { CharacterAsset.flush_for_character(character_id) }

    specify { CharacterAsset.count.should == 0 }
  end

  describe "station_id?" do
    specify { CharacterAsset.send(:station_id?, 30000001).should be_false }
    specify { CharacterAsset.send(:station_id?, 66666666).should be_false }
    specify { CharacterAsset.send(:station_id?, 60000001).should be_true }
  end

  describe "lookup_system" do
    context "with station, no cache" do
      before { Station.should_receive(:find_by_station_id).with(location_id).and_return(station) }
      specify { CharacterAsset.send(:lookup_system, location_id).should == system_id }
    end

    context "with system" do
      specify { CharacterAsset.send(:lookup_system, system_id).should == system_id }
    end
  end
end
