require 'spec_helper'

describe Api::V1::SolarSystemsController do
  render_views

  let(:s1) { FactoryGirl.build(:solar_system) }
  let(:s2) { FactoryGirl.build(:solar_system) }

  let(:c1) { FactoryGirl.build(:constellation) }
  let(:r1) { FactoryGirl.build(:region) }

  before { s1.stub(:constellation).and_return(c1) }
  before { s2.stub(:constellation).and_return(c1) }
  before { s1.stub(:region).and_return(r1) }
  before { s2.stub(:region).and_return(r1) }

  describe "getting a system list" do
    let(:records) { [s1, s2] }
    before { records.stub(:paginate).with(page_params).and_return([s1]) }

    context "without a query string" do
      let(:page_params) { {:page => 1, :per_page => 1} }
      before { SolarSystem.stub(:order).and_return(records) }
      before { get :index, page: '1', per_page: '1'}

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject['pagination']['page'].should == 1 }
      specify { subject['pagination']['per_page'].should == 1 }
      specify { subject['pagination']['pages'].should == 2 }
      specify { subject['pagination']['total'].should == 2 }
      specify { subject['pagination']['next'].should == api_solar_systems_path(page: 2, per_page: 1) }

      specify { subject['solar_systems'].should have(1).thing }
      specify { subject['solar_systems'].first.keys.should have(8).things }
      specify { subject['solar_systems'].first['solar_system_id'].should == s1.id }
      specify { subject['solar_systems'].first['name'].should == s1.name }
      specify { subject['solar_systems'].first['links']['self']['href'].should == api_solar_system_path(s1) }
      specify { subject['solar_systems'].first['links']['region']['href'].should == api_region_path(s1.region_id) }
    end

    context "with a query string" do
      let(:page_params) { {:page => 2, :per_page => 1} }
      before { SolarSystem.should_receive(:by_name).with('test').and_return(records) }
      before { records.stub(:order).and_return(records) }
      before { get :index, q: 'test', page: '2', per_page: '1' }

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject['pagination']['page'].should == 2 }
      specify { subject['pagination']['per_page'].should == 1 }
      specify { subject['pagination']['pages'].should == 2 }
      specify { subject['pagination']['total'].should == 2 }
      specify { subject['pagination']['prev'].should == api_solar_systems_path(page: 1, per_page: 1) }

      specify { subject['solar_systems'].should have(1).thing }
      specify { subject['solar_systems'].first.keys.should have(8).things }
      specify { subject['solar_systems'].first['solar_system_id'].should == s1.id }
    end
  end

  describe "getting a system" do
    context "with a valid region id" do
      before { SolarSystem.stub_chain(:includes, :find).and_return(s1) }
      before { get :show, :format => :json, :id => s1.solar_system_id }

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject.should have(9).things }
      specify { subject['solar_system_id'].should == s1.solar_system_id }
      specify { subject['name'].should == s1.name }
      specify { subject['security'].should == s1.security }
      specify { subject['region_id'].should == s1.region_id }
      specify { subject['region_name'].should == s1.region_name }
      specify { subject['constellation_id'].should == s1.constellation_id }
      specify { subject['constellation_name'].should == s1.constellation_name }
      specify { subject['links']['region']['href'].should == api_region_path(s1.region_id) }
    end

    context "with a valid system id, not found" do
      before { SolarSystem.stub_chain(:includes, :find).and_raise(ActiveRecord::RecordNotFound) }

      before { get :show, :format => :json, :id => s2.region_id }

      specify { response.status.should == 404 }
    end

    context "with an invalid system id" do
      before { get :show, :format => :json, :id => 'abc' }
      specify { response.status.should == 400 }
    end
  end

  describe "names" do
    let(:retval) { [{'name' => s1.name,
                     'solar_system_id' => s1.id,
                     'links' => {'self' => {'href' => api_solar_system_path(s1)}}}] }
    let(:s1) { FactoryGirl.build(:solar_system) }
    before { SolarSystem.should_receive(:names).with('abc').and_return([s1]) }

    before { get :names, q: 'abc' }

    subject { JSON.parse(response.body) }

    specify { response.should be_success }

    specify { subject.should == retval }
  end
end
