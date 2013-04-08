require 'spec_helper'

describe Account do
  let(:key) { FactoryGirl.create(:api_key) }
  let(:user) { FactoryGirl.create(:user) }

  let!(:ac) { Account.create({key_id: key.key_id, user_id: user.id,
                              logon_count: 9},
                              without_protection: true) }

  describe "building from the api" do
    let(:result) { OpenStruct.new(paidUntil: 1.month.from_now,
                                  logonCount: 25) }

    before { Account.update_from_api(key.key_id, result) }

    specify { Account.first.logon_count.should == 25 }
  end
end
