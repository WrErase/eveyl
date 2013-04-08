require 'spec_helper.rb'

describe Region do
  let!(:r1) { FactoryGirl.create(:region, name: 'RegionA',
                                          region_id: 2, has_hub: true) }
  let!(:r2) { FactoryGirl.create(:region, name: 'A-B', region_id: 1) }

  describe "finding by name" do
    specify { Region.by_name('nA').should == [r1] }
    specify { Region.by_name('abcd').should be_empty }
  end

  describe "names" do
    context "all" do
      subject { Region.names }
      specify { subject.should have(2).things }
      specify { subject.first.id.should == r2.id }
      specify { subject.first.name.should == r2.name }
      specify { subject.last.id.should == r1.id }
      specify { subject.last.name.should == r1.name }
    end

    context "search" do
      subject { Region.names('iona') }
      specify { subject.should have(1).thing }
      specify { subject.first.id.should == r1.id }
      specify { subject.first.name.should == r1.name }
    end
  end

  describe "normal regions" do
    specify { Region.normal.should == [r1] }
  end

  describe "getting hub region ids" do
    specify { Region.hub_region_ids.should == [r1.id] }
  end

  describe "dotlan url" do
    let(:url) { "http://evemaps.dotlan.net/map/The_Forge" }
    before { r1.name = 'The Forge' }

    specify { r1.dotlan_url.should == url }
  end

  describe "getting order histories for hubs" do
    let(:ts1) { 1.day.ago }
    let(:ts2) { 2.days.ago }

    let(:oh1) { double('order_history', outlier?: false, ts: ts1, avg: 1) }
    let(:oh2) { double('order_history', outlier?: false, ts: ts2, avg: 2) }
    let(:oh3) { double('order_history', outlier?: false, ts: ts1, avg: 3) }
    let(:oh4) { double('order_history', outlier?: true, ts: ts2, avg: 4) }

    before { Region.stub(:has_hub).and_return([r1, r2]) }
    before { r1.should_receive(:order_histories_for_type)
               .with(34)
               .and_return([oh1, oh2]) }
    before { r2.should_receive(:order_histories_for_type)
               .with(34)
               .and_return([oh3, oh4]) }

    let(:histories) { {"region_a"=>[[ts1.to_i * 1000, 1], [ts2.to_i * 1000, 2]],
                       "a_b" => [[ts1.to_i * 1000, 3], [ts2.to_i * 1000, nil]]} }
    specify { Region.order_histories_for_hubs(34).should == histories }

  end

  describe "regions with high sec systems" do
    before { FactoryGirl.create(:solar_system, security: 0.9,
                                               region_id: r1.id) }
    before { FactoryGirl.create(:solar_system, security: 0.1,
                                               region_id: r2.id) }

    describe "getting the regions" do
      specify { Region.has_high_sec.should == [r1] }
    end

    describe 'with high system, region_ids' do
      specify { Region.with_high_sec_ids.should == [r1.id] }
    end

    describe "testing if a region has high sec" do
      specify { Region.has_high_sec?(r1.id).should be_true }
      specify { Region.has_high_sec?(r2.id).should be_false }
    end
  end
end
