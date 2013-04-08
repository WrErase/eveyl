require 'spec_helper'

describe ApiKey do
  describe "getting the admin key" do
    let!(:user) { FactoryGirl.create(:user, admin: true) }
    let!(:key) { FactoryGirl.create(:api_key, user_id: user.id) }

    specify { ApiKey.admin_key.should == key }
  end
end
