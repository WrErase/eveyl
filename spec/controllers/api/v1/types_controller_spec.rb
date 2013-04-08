require 'spec_helper'

describe Api::V1::TypesController do
  render_views

  let(:t1) { FactoryGirl.build(:type) }
  let(:t2) { FactoryGirl.build(:type) }

  describe "getting a type list" do
    let(:records) { [t1, t2] }
    before { records.stub(:paginate).with(page_params).and_return([t1]) }

    let(:type) { double('type') }

    context "without a query string" do
      let(:page_params) { {:page => 1, :per_page => 1} }

      before { Type.stub(:on_market).and_return(records) }
      before { get :index, page: '1', per_page: '1'}

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject['pagination']['page'].should == 1 }
      specify { subject['pagination']['per_page'].should == 1 }
      specify { subject['pagination']['pages'].should == 2 }
      specify { subject['pagination']['total'].should == 2 }
      specify { subject['pagination']['next'].should == api_types_path(page: 2, per_page: 1) }

      specify { subject['types'].should have(1).thing }
      specify { subject['types'].first.keys.should have(6).things }
      specify { subject['types'].first['type_id'].should == t1.id }
      specify { subject['types'].first['name'].should == t1.name }
      specify { subject['types'].first['links']['self']['href'].should == api_type_path(t1) }
      specify { subject['types'].first['links']['order_histories']['href'].should == api_type_order_histories_path(t1) }
    end

    context "with a query string" do
      let(:page_params) { {:page => 2, :per_page => 1} }

      before { Type.stub(:on_market).and_return(records) }
      before { records.should_receive(:find_by_name).with('test').and_return(records) }

      before { get :index, q: 'test', page: '2', per_page: '1'}

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject['pagination']['page'].should == 2 }
      specify { subject['pagination']['per_page'].should == 1 }
      specify { subject['pagination']['pages'].should == 2 }
      specify { subject['pagination']['total'].should == 2 }
      specify { subject['pagination']['prev'].should == api_types_path(page: 1, per_page: 1) }

      specify { subject['types'].should have(1).thing }
      specify { subject['types'].first.keys.should have(6).things }
      specify { subject['types'].first['type_id'].should == t1.id }
    end
  end

  describe "getting a type" do
    context "with a valid type id" do
      before { Type.stub(:find).and_return(t1) }
      before { get :show, :format => :json, :id => t1.type_id }

      subject { JSON.parse(response.body) }

      specify { response.should be_success }

      specify { subject.should have(7).things }
      specify { subject['type_id'].should == t1.type_id }
      specify { subject['name'].should == t1.name }
      specify { subject['tech_level'].should == t1.tech_level }
      specify { subject['meta_level'].should == t1.meta_level }
    end

    context "with a valid type id, not found" do
      before { Type.stub(:find).and_raise(ActiveRecord::RecordNotFound) }

      before { get :show, :format => :json, :id => t2.type_id }

      specify { response.status.should == 404 }
    end

    context "with an invalid type id" do
      before { get :show, :format => :json, :id => 'abc' }
      specify { response.status.should == 400 }
    end
  end

  describe "names" do
    let(:retval) { [{'name' => t1.name,
                     'type_id' => t1.id,
                     'links' => {'self' => {'href' => api_type_path(t1.id) }}}]}
#    let(:t1) { FactoryGirl.build(:type) }
    before { Type.should_receive(:names).with(true, 'abc').and_return([t1]) }

    before { get :names, q: 'abc' }

    subject { JSON.parse(response.body) }

    specify { response.should be_success }

    specify { subject.should == retval }
  end
end
