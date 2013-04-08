require 'spec_helper'

describe User do
  let(:key) { FactoryGirl.create(:api_key) }
  let(:user) { FactoryGirl.create(:user) }

  let!(:ac) { Account.create({key_id: key.key_id, user_id: user.id},
                              without_protection: true) }

  let!(:c1) { FactoryGirl.create(:character, key_id: key.key_id) }
  let!(:c2) { FactoryGirl.create(:character, key_id: key.key_id) }
  let!(:c3) { FactoryGirl.create(:character, key_id: 999) }

  describe "getting accounts" do
    specify { user.accounts.should == [ac] }
  end

  describe "getting character ids" do
    specify { user.character_ids.should == [c1.character_id, c2.character_id] }
  end
end
