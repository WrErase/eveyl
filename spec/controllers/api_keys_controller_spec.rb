require 'spec_helper'

describe ApiKeysController do
  let(:key) { double('key') }
  let(:keys) { double('api_keys') }

  let(:user) { FactoryGirl.create(:user) }

  before {
    sign_in user
    subject.stub(:current_user).and_return(user)
  }

  describe "show" do
    before { user.stub(:api_keys).and_return(keys) }

    context "not found" do
      before { keys.should_receive(:find).with('1').and_return(nil) }

      before { get :show, id: '1' }

      specify { flash[:alert].should == 'Key Not Found' }
      specify { response.should be_redirect }
    end

    context "found" do
      before { keys.should_receive(:find).with('1').and_return(key) }

      before { get :show, id: '1' }

      specify { assigns[:key].should == key }
    end
  end

  describe "create" do
    let(:params) { {"api_key" => {"key_id" => '1', "vcode" => 'a' * 64} } }

    context "success" do
      let(:key) { double('api_key', test_key: true, valid?: true, save: true) }
      before { user.api_keys.should_receive(:build)
                            .with(params['api_key']).and_return(key) }
      before { post :create, params }

      specify { flash[:notice].should == 'Added API Key' }
      specify { response.status.should == 201 }
      specify { assigns[:key_passed].should be_true }
    end

    context "invalid key params" do
      let(:key) { double('api_key', test_key: false, valid?: true, save: true) }
      before { user.api_keys.should_receive(:build)
                            .with(params['api_key']).and_return(key) }
      before { post :create, params }

      specify { response.should be_redirect }
      specify { flash[:alert].should == "Key Creation Failed" }
      specify { assigns[:key_passed].should be_false }
    end

    context "key save failed" do
      let(:key) { double('api_key', test_key: true, valid?: true, save: false) }
      before { user.api_keys.should_receive(:build)
                            .with(params['api_key']).and_return(key) }
      before { post :create, params }

      specify { response.should be_redirect }
      specify { flash[:alert].should == "Key Creation Failed" }
      specify { assigns[:key_passed].should be_true }
    end
  end

  describe "destroy" do
    before { user.stub(:api_keys).and_return(keys) }

    context "not found" do
      before { keys.should_receive(:find).with('1').and_return(nil) }

      before { delete :destroy, id: '1' }

      specify { flash[:alert].should == 'Key Not Found' }
      specify { response.should be_redirect }
    end

    context "success" do
      before { keys.should_receive(:find).with('1').and_return(key) }
      before { key.should_receive(:destroy).and_return(true) }
      before { delete :destroy, id: '1' }

      specify { flash[:notice].should == 'Key Deleted' }
      specify { response.should be_redirect }
    end
  end
end
