require 'spec_helper.rb'

describe Type do
  let!(:t1) { FactoryGirl.create(:type, name: 'TypeA', market_group_id: 1) }
  let!(:t2) { FactoryGirl.create(:type, name: 'TypeB', market_group_id: 1) }
  let!(:t3) { FactoryGirl.create(:type, name: 'TypeB2', market_group_id: nil) }
  let!(:t4) { FactoryGirl.create(:type, name: 'TypeB3', market_group_id: 1, published: false) }

  describe "type market ids" do
    specify { Type.on_market_ids.should == [t1.id, t2.id] }
  end

  describe "finding by name" do
    specify { Type.find_by_name('ypeb').should == [t2, t3, t4] }
  end

  describe "getting names " do
    context "all" do
      let(:names) { Type.names(false, 'ypeb') }
      specify { names.map(&:name).should == ['TypeB', 'TypeB2'] }
    end

    context "market" do
      let(:names) { Type.names(true, 'ypeb') }
      specify { names.map(&:name).should == ['TypeB'] }
    end

    context "no query" do
      let(:names) { Type.names(false) }
      specify { names.map(&:name).should == ['TypeA', 'TypeB', 'TypeB2'] }
    end
  end

  describe "type categories" do
    let(:atype) { FactoryGirl.build(:type, name: 'Hat Blueprint') }
    specify { atype.is_blueprint?.should be_true }
  end

  describe "values" do
    let!(:value) { FactoryGirl.create(:type_value, type_id: t1.type_id,
                                          ts: Time.parse('2013-01-01'),
                                          region_id: 10000002, stat: 'median',
                                          value: 100.91, mat_value: 90.10) }
    let(:profile) { FactoryGirl.build(:user_profile, default_stat: 'median',
                                          default_region: 10000002) }
    let(:user) { double('user', user_profile: profile) }

    describe "last type value" do
      context "with user" do
        before { TypeValue.should_receive(:find_by_region_stat)
                          .with(t1.type_id, profile.default_region,
                                profile.default_stat)
                          .and_return(2) }
        specify { t1.last_type_value(user).should == 2 }
      end

      context "without user" do
        before { TypeValue.should_receive(:find_by_region_stat)
                          .with(t1.type_id)
                          .and_return(3) }
        specify { t1.last_type_value.should == 3 }
      end
    end

    describe "market value" do
      specify { t1.mkt_value(user).should == 100.91 }
    end

    describe "material value" do
      specify { t1.mat_value(user).should == 90.10 }
    end

    describe "material percentage" do
      specify { t1.mat_perc(user).should == 89.3 }
    end

    describe "value timestamp" do
      specify { t1.value_ts(user).should == Time.parse('2013-01-01') }
    end
  end

  describe "attributes" do
    describe "tech_level" do
      let!(:at1) { FactoryGirl.create(:attribute_type, :name => 'metaLevel') }
      let!(:ta1) { FactoryGirl.create(:type_attribute, :type_id => t1.id, :attribute_id => at1.id, :value_int => 1) }
      specify { t1.attribute_value('metaLevel').should == 1 }
    end

    describe "meta_level" do
      let!(:at2) { FactoryGirl.create(:attribute_type, :name => 'techLevel') }
      let!(:ta2) { FactoryGirl.create(:type_attribute, :type_id => t1.id, :attribute_id => at2.id, :value_int => 2) }
      specify { t1.attribute_value('techLevel').should == 2 }
    end
  end
end
