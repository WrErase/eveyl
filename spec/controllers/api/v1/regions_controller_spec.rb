require 'spec_helper'

describe Api::V1::RegionsController do
  render_views

  let(:r1) { FactoryGirl.build(:region) }
  let(:r2) { FactoryGirl.build(:region) }

  describe "getting a system list" do
    let(:records) { [r1, r2] }
    before { records.stub(:paginate).with(page_params).and_return([r1]) }

    context "without a query string" do
      let(:page_params) { {:page => 1, :per_page => 1} }
      before { Region.stub(:order).and_return(records) }
      before { get :index, page: '1', per_page: '1'}

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject['pagination']['page'].should == 1 }
      specify { subject['pagination']['per_page'].should == 1 }
      specify { subject['pagination']['pages'].should == 2 }
      specify { subject['pagination']['total'].should == 2 }
      specify { subject['pagination']['next'].should == api_regions_path(page: 2, per_page: 1) }

      specify { subject['regions'].should have(1).thing }
      specify { subject['regions'].first.keys.should have(3).things }
      specify { subject['regions'].first['region_id'].should == r1.id }
      specify { subject['regions'].first['name'].should == r1.name }
      specify { subject['regions'].first['links']['self']['href'].should == api_region_path(r1) }
      specify { subject['regions'].first['links']['solar_systems']['href'].should == api_region_solar_systems_path(r1) }
    end

    context "with a query string" do
      let(:page_params) { {:page => 2, :per_page => 1} }
      before { Region.should_receive(:by_name).with('test').and_return(records) }
      before { records.stub(:order).and_return(records) }
      before { get :index, q: 'test', page: '2', per_page: '1' }

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject['pagination']['page'].should == 2 }
      specify { subject['pagination']['per_page'].should == 1 }
      specify { subject['pagination']['pages'].should == 2 }
      specify { subject['pagination']['total'].should == 2 }
      specify { subject['pagination']['prev'].should == api_regions_path(page: 1, per_page: 1) }

      specify { subject['regions'].should have(1).thing }
      specify { subject['regions'].first.keys.should have(3).things }
      specify { subject['regions'].first['region_id'].should == r1.id }
    end
  end

  describe "getting a region" do
    context "with a valid region id" do
      before { Region.stub_chain(:includes, :find).and_return(r1) }
      before { get :show, :format => :json, :id => r1.region_id }

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject.should have(6).things }
      specify { subject['region_id'].should == r1.region_id }
      specify { subject['name'].should == r1.name }
      specify { subject['faction_id'].should == r1.faction_id }
      specify { subject['has_hub'].should == r1.has_hub }
    end

    context "with a valid region id, not found" do
      before { Region.stub_chain(:includes, :find).and_raise(ActiveRecord::RecordNotFound) }

      before { get :show, :format => :json, :id => r2.region_id }

      specify { response.status.should == 404 }
    end

    context "with an invalid system id" do
      before { get :show, :format => :json, :id => 'abc' }
      specify { response.status.should == 400 }
    end
  end

  describe "names" do
    let(:retval) { [{'name' => r1.name,
                     'region_id' => r1.id,
                     'links' => {'self' => {'href' => api_region_path(r1.id) }}}]}
    let(:s1) { FactoryGirl.build(:region) }
    before { Region.should_receive(:names).with('abc').and_return([r1]) }

    before { get :names, q: 'abc' }

    subject { JSON.parse(response.body) }

    specify { response.should be_success }

    specify { subject.should == retval }
  end
end
