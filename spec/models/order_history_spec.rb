require 'spec_helper.rb'

describe OrderHistory do
  describe "stat validation" do
    context "high less than low" do
      subject  { FactoryGirl.build(:order_history, low: 10, high: 1) }
      specify { subject.valid?.should be_false }
      specify { subject.errors['low'].should_not be_nil }
    end

    context "average greater than high" do
      subject  { FactoryGirl.build(:order_history, average: 10, high: 1) }
      specify { subject.valid?.should be_false }
      specify { subject.errors['average'].should_not be_nil }
    end

    context "average less than low" do
      subject  { FactoryGirl.build(:order_history, average: 1, low: 10) }
      specify { subject.valid?.should be_false }
      specify { subject.errors['average'].should_not be_nil }
    end
  end

  describe "stringify" do
    let(:oh) { FactoryGirl.build(:order_history) }
    before { oh.stub(:type).and_return(double('type', name: 'tn')) }
    before { oh.stub(:region).and_return(double('region', name: 'rn')) }
    before { oh.stub(:ts).and_return('123') }

    specify { oh.to_s.should == "tn / rn / 123" }
  end

  describe "type query" do
    let!(:oh1) { FactoryGirl.create(:order_history, type_id: 1, region_id: 1, ts: 1.hour.ago) }
    let!(:oh2) { FactoryGirl.create(:order_history, type_id: 1, region_id: 1, ts: 2.days.ago) }
    let!(:oh3) { FactoryGirl.create(:order_history, type_id: 1, region_id: 2, ts: 3.hours.ago) }
    let!(:oh4) { FactoryGirl.create(:order_history, type_id: 1, region_id: 3, ts: 4.hours.ago) }
    let!(:oh5) { FactoryGirl.create(:order_history, type_id: 2, region_id: 1, ts: 5.hours.ago) }

    specify { OrderHistory.type_query(1, 1, 1).should == [oh1] }
    specify { OrderHistory.type_query(1, 1, 5).should == [oh1, oh2] }
    specify { OrderHistory.type_query(1, 2, 1).should == [oh3] }
    specify { OrderHistory.type_query(1, nil, 1).should == [oh1, oh3, oh4] }
    specify { OrderHistory.type_query(1, nil, nil).should == [oh1, oh3, oh4, oh2] }
    specify { OrderHistory.type_query(2, nil, nil).should == [oh5] }
    specify { OrderHistory.type_query(3, nil, nil).should == [] }
  end

  describe "flagging outliers" do
    let(:type_id) { 34 }
    #TODO - Cleanup - use association for type
    before { Type.stub(:on_market_ids).and_return([type_id]) }

    let!(:oh1) { FactoryGirl.create(:order_history, type_id: type_id, low: 1, high: 500, average: 1) }
    let!(:oh2) { FactoryGirl.create(:order_history, type_id: type_id, low: 1, high: 500, average: 10) }
    let!(:oh3) { FactoryGirl.create(:order_history, type_id: type_id, low: 1, high: 500, average: 15) }
    let!(:oh4) { FactoryGirl.create(:order_history, type_id: type_id, low: 1, high: 500, average: 21) }
    let!(:oh5) { FactoryGirl.create(:order_history, type_id: type_id, low: 1, high: 500, average: 5) }
    let!(:oh6) { FactoryGirl.create(:order_history, type_id: type_id, low: 1, high: 500, average: 500) }

    before { OrderHistory.flag_outliers }
    before { [oh1, oh2, oh3, oh4, oh5, oh6].each { |h| h.reload } }

    specify {
      oh1.outlier.should be_false
      oh2.outlier.should be_false
      oh3.outlier.should be_false
      oh4.outlier.should be_false
      oh5.outlier.should be_false
      oh6.outlier.should be_true
    }
  end
end
