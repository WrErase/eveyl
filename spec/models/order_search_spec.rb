require 'spec_helper'

describe OrderSearch do
  let(:search) { OrderSearch.new }

  describe "extracting bid param" do
    specify { lambda {search.extract_bid_param({bid: 'a'})}.should
                                     raise_error OrderSearch::InvalidQuery }
    specify { search.extract_bid_param({bid: '1'}).should be_true }
    specify { search.extract_bid_param({bid: '0'}).should be_false }
  end

  describe "extracting order param" do
    specify { lambda {search.extract_order_param({order_id: 'a'})}.should
                                     raise_error OrderSearch::InvalidQuery }
    specify { search.extract_order_param({order_id: '12'}).should == 12 }
  end

  describe "extracting region param" do
    specify { lambda {search.extract_region_param({region_id: 'a'})}.should
                                     raise_error OrderSearch::InvalidQuery }
    specify { search.extract_region_param({region_id: '12345678'}).should == 12345678 }
  end

  describe "extracting type param" do
    specify { lambda {search.extract_type_param({type_id: 'a'})}.should
                                     raise_error OrderSearch::InvalidQuery }
    specify { search.extract_type_param({type_id: '123'}).should == 123 }
  end

  describe "extracting sec param" do
    specify { lambda {search.extract_sec_param({high_sec: 'a'})}.should
                                     raise_error OrderSearch::InvalidQuery }
    specify { search.extract_sec_param({high_sec: '1'}).should be_true }
    specify { search.extract_sec_param({high_sec: '0'}).should be_false }
  end

  describe "extracting hour param" do
    specify { search.extract_hour_param({}).should == 60_000 }
    specify { search.extract_hour_param({hours: '1'}).should == 1 }
  end

  describe "building the query" do
    let!(:o1) { FactoryGirl.create(:buy_order, order_id: 123, type_id: 34,
                                    region_id: 12345678,
                                    reported_ts: 1.hour.ago) }

    let(:params) { {bid: '1', type_id: '34', region_id: '12345678',
                    hours: '24'} }

    let(:search) { OrderSearch.new }
    before { search.load_params(params) }

    specify { search.build_query.should have(1).thing }
    specify { search.build_query.first.order_id.should == 123 }
  end
end
