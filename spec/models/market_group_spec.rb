require 'spec_helper.rb'

describe MarketGroup do
  describe "group_chain" do
    let!(:g1) { FactoryGirl.create(:market_group, market_group_id: 1,
                                                  parent_group_id: nil) }
    let!(:g2) { FactoryGirl.create(:market_group, market_group_id: 2,
                                                  parent_group_id: 1) }
    let!(:g3) { FactoryGirl.create(:market_group, market_group_id: 3,
                                                  parent_group_id: 2) }

    specify { g1.group_chain.should == [g1] }
    specify { g3.group_chain.should == [g1, g2, g3] }
  end

end
