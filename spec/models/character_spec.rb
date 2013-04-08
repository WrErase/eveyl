require 'spec_helper'

describe Character do
  let(:asset) { double('asset') }
  let(:result) { double('result', assets: [asset]) }
  let(:char) { FactoryGirl.build(:character, id: 1) }

  describe "building assets" do
    before { CharacterAsset.should_receive(:create_from_api)
                           .with(1, asset) }

    specify { char.build_assets(result) }
  end

  describe "total sp" do
    let(:skill) { CharacterSkill.new(skill_points: 1000) }
    before { char.stub(:skills).and_return([skill, skill]) }

    specify { char.total_sp.should == 2000 }
  end
end
