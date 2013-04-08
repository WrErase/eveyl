require 'spec_helper.rb'

describe Sovereignty do

  describe "update from api" do
    context "no existing record" do
      let(:sov) { FactoryGirl.build(:sovereignty) }
      let(:update) { OpenStruct.new(solarSystemID: sov.solar_system_id,
                                    factionID: sov.faction_id,
                                    allianceID: sov.alliance_id,
                                    corporationID: sov.corporation_id) }

      before { Sovereignty.update_from_api(update, sov.data_time) }

      specify { Sovereignty.count.should == 1 }
      specify { Sovereignty.first.should == sov }
    end

    context "existing record" do
      let(:sov) { FactoryGirl.create(:sovereignty) }
      let(:update) { OpenStruct.new(solarSystemID: sov.solar_system_id,
                                    factionID: sov.faction_id,
                                    allianceID: sov.alliance_id,
                                    corporationID: sov.corporation_id) }

      before { Sovereignty.update_from_api(update, sov.data_time) }

      specify { Sovereignty.count.should == 1 }
      specify { Sovereignty.first.should == sov }
    end
  end

  describe "owner changed?" do
    context "alliance changed" do
      let(:sov) { FactoryGirl.create(:sovereignty) }
      before { sov.alliance_id = sov.alliance_id + 1 }

      specify { sov.owner_changed?.should be_true }
    end

    context "corporation changed" do
      let(:sov) { FactoryGirl.create(:sovereignty) }
      before { sov.corporation_id = sov.corporation_id + 1 }

      specify { sov.owner_changed?.should be_true }
    end

    context "data_time changed" do
      let(:sov) { FactoryGirl.create(:sovereignty) }
      before { sov.data_time += 60 }

      specify { sov.owner_changed?.should be_false }
    end
  end

  describe "saving history when the owner changes" do
    context "owner changed" do
      let(:old_alliance_id) { 1 }
      let(:old_corp_id) { 2 }
      let(:sov) { FactoryGirl.create(:sovereignty, alliance_id: old_alliance_id,
                                                   corporation_id: old_corp_id) }
      before { sov.alliance_id = sov.alliance_id + 1 }
      before { sov.save }

      specify { SovereigntyHistory.count.should == 1 }
      specify { SovereigntyHistory.first.alliance_id = old_alliance_id }
      specify { SovereigntyHistory.first.corporation_id = old_corp_id }
    end

    context "no owner change" do
      let(:sov) { FactoryGirl.create(:sovereignty) }

      before { sov.save }

      specify { SovereigntyHistory.count.should == 0 }
    end
  end

end

