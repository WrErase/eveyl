require 'spec_helper.rb'

describe Order do
  let(:type_id) { 34 }
  let(:r1) { FactoryGirl.create(:region) }
  let(:t1) { FactoryGirl.create(:type, :type_id => type_id) }

  describe "should correctly set expiration on save" do
    context "not expired" do
      let(:issued) { 4.hours.ago }
      let(:o1) { FactoryGirl.create(:sell_order, :issued => issued, :duration => 90) }

      specify { o1.expires.should == issued + 90.days }
      specify { o1.expired?.should be_false }
      specify { o1.valid?.should be_true }
    end

    context "expired" do
      let(:issued) { 3.days.ago }
      let(:o1) { FactoryGirl.create(:sell_order, :issued => issued, :duration => 1) }

      specify { o1.expires.should == issued + 1.days }
      specify { o1.expired?.should be_true }
      specify { o1.valid?.should be_true }
    end
  end

  describe "should create a log on save if fields have changed" do
    context "fields have changed" do
      let(:o1) { FactoryGirl.create(:sell_order) }

      let(:new_price) { o1.price - 0.05 }

      before { OrderLog.should_receive(:log_order).with(o1).and_return(true) }
      before { o1.price = new_price }

      specify { o1.save.should be_true }
    end

    context "unimportant fields have changed" do
      let(:o1) { FactoryGirl.create(:sell_order) }
      before { o1.gen_name += '2' }

      before { OrderLog.should_not_receive(:log_order) }

      specify { o1.save.should be_true }
    end

    context "new record" do
      let(:o1) { FactoryGirl.build(:sell_order) }

      before { OrderLog.should_not_receive(:log_order) }

      specify { o1.save.should be_true }
    end
  end

  describe "destroying an order should also clear its logs" do
    let(:o1) { FactoryGirl.create(:sell_order) }
    let(:log) { FactoryGirl.create(:order_log, :order_id => o1.id) }

    before { o1.destroy }
    specify { OrderLog.count.should == 0 }
  end

  describe "timestamp validations" do
    context "no errors" do
      let(:o1) { FactoryGirl.build(:sell_order, :reported_ts => 1.hour.ago, :issued => 2.hours.ago) }
      specify { o1.valid?.should be_true }
    end

    context "empty reported_ts" do
      let(:o1) { FactoryGirl.build(:sell_order, :reported_ts => nil, :issued => 2.hours.ago) }
      specify { o1.valid?.should be_false }
    end

    context "empty issued" do
      let(:o1) { FactoryGirl.build(:sell_order, :reported_ts => 1.hour.ago, :issued => nil) }
      specify { o1.valid?.should be_false }
    end

#    context "reported date too old" do
#      let(:o1) { FactoryGirl.build(:sell_order, :reported_ts => 2.years.ago) }
#      specify { o1.valid?.should be_false }
#    end

#    context "reported date in the future" do
#      let(:o1) { FactoryGirl.build(:sell_order, :reported_ts => 45.minutes.from_now) }
#      specify { o1.valid?.should be_false }
#    end

#    context "issued date too old" do
#      let(:o1) { FactoryGirl.build(:sell_order, :issued => 2.years.ago) }
#      specify { o1.valid?.should be_false }
#    end

    context "issued date in the future" do
      let(:o1) { FactoryGirl.build(:sell_order, :issued => 45.minutes.from_now) }
      specify { o1.valid?.should be_false }
    end

    context "issued after reported" do
      let(:o1) { FactoryGirl.build(:sell_order, :reported_ts => 2.hours.ago,  :issued => 1.hour.ago) }
      specify { o1.valid?.should be_false }
    end
  end

  describe "volume validations" do
    context "no errors" do
      let(:o1) { FactoryGirl.build(:sell_order, :vol_remain => 10, :vol_enter => 20) }
      specify { o1.valid?.should be_true }
    end

    context "missing vol_remain" do
      let(:o1) { FactoryGirl.build(:sell_order, :vol_remain => nil, :vol_enter => 20) }
      specify { o1.valid?.should be_false }
    end

    context "missing vol_enter" do
      let(:o1) { FactoryGirl.build(:sell_order, :vol_remain => 10, :vol_enter => nil) }
      specify { o1.valid?.should be_false }
    end

    context "vol_remain greater than vol_enter" do
      let(:o1) { FactoryGirl.build(:sell_order, :vol_remain => 30, :vol_enter => 20) }
      specify { o1.valid?.should be_false }
    end
  end

  describe "checking changes" do
    let(:o1) { FactoryGirl.create(:sell_order, :vol_enter => 30, :vol_remain => 20,
                                               :reported_ts => 1.hour.ago,
                                               :issued => 2.hours.ago) }
    context "vol_remain increases" do
      before { o1.vol_remain = 30 }
      specify {
        o1.valid?.should be_false
        o1.errors[:vol_remain].should_not be_nil
      }
    end

    context "reported_ts increases" do
      before { o1.reported_ts = 2.hours.ago }
      specify {
        o1.valid?.should be_false
        o1.errors[:reported_ts].should_not be_nil
      }
    end

    context "issued increases" do
      before { o1.issued = 3.hours.ago }
      specify {
        o1.valid?.should be_false
        o1.errors[:issued].should_not be_nil
      }
    end

  end

  describe "save if new" do
    let(:order_id) { 42 }
    let(:reported) { 8.hours.ago }
    let(:issued) { 1.day.ago }
    let(:upload) { {:vol_remain => 12,
                    :order_id => order_id,
                    :station_id => 60003760,
                    :type_id => 34,
                    :vol_enter => 20,
                    :min_vol => 1,
                    :issued => issued.to_s,
                    :reported_ts => reported.to_s,
                    :gen_name => 'Test',
                    :duration => 30,
                    :price => 4,
                    :range => 1,
                    :bid => true } }

    subject { Order.save_if_new(upload)}

    context "with an existing newer order" do
      let!(:order) { FactoryGirl.create(:buy_order,
                                        :price => 8,
                                        :reported_ts => reported + 1.hour,
                                        :order_id => order_id) }

      specify { subject.should == nil }
      specify { Order.count.should == 1 }
    end

    context "with no existing order" do
      specify {
        subject.should_not be_nil
        subject.reported_ts.to_s.should == reported.to_s
        subject.price.should == upload[:price]
        Order.count.should == 1
      }
    end
  end

  describe "handling outliers" do
    let!(:o1) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 1) }
    let!(:o2) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 147) }
    let!(:o3) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 49) }
    let!(:o4) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 40) }
    let!(:o5) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 42) }
    let!(:o6) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 41) }
    let!(:o7) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 43) }
    let!(:o8) { FactoryGirl.create(:buy_order, type: t1,
                                               region: r1, price: 42) }

    describe "updating outliers" do
      before { Order.flag_outliers(t1.type_id, r1.region_id, [31, 52]) }
      before { [o1, o2, o3, o4, o5, o6, o7, o8].each { |o| o.reload } }

      specify {
        o1.outlier.should be_true
        o2.outlier.should be_true
        o3.outlier.should be_false
        o4.outlier.should be_false
        o5.outlier.should be_false
        o6.outlier.should be_false
        o7.outlier.should be_false
        o8.outlier.should be_false
      }
    end

    describe "clearing old outlier flags" do
      let!(:o5) { FactoryGirl.create(:buy_order, type: t1, region: r1,
                                                 price: 42, outlier: true) }
      let!(:o6) { FactoryGirl.create(:buy_order, type: t1, region: r1,
                                                 price: 41, outlier: true) }
      let!(:o7) { FactoryGirl.create(:buy_order, type: t1, region: r1,
                                                 price: 43, outlier: true) }
      let!(:o8) { FactoryGirl.create(:buy_order, type: t1, region: r1,
                                                 price: 42, outlier: true) }

      before { Order.flag_outliers(t1.type_id, r1.region_id, [31, 52]) }
      before { [o1, o2, o3, o4, o5, o6, o7, o8].each { |o| o.reload } }

      specify {
        o1.outlier.should be_true
        o2.outlier.should be_true
        o3.outlier.should be_false
        o4.outlier.should be_false
        o5.outlier.should be_false
        o6.outlier.should be_false
        o7.outlier.should be_false
        o8.outlier.should be_false
      }
    end

    describe "updating outliers" do
      before { Type.stub(:type_list).and_return([t1]) }
      before { Region.stub(:all).and_return([r1]) }

      context "with enough orders" do
#        before { Order.stub_chain(:active, :where).and_return([o1, o2, o3, o4, o5, o6, o7, o8]) }
        before { Order.stub_chain(:active, :where, :pluck)
                         .and_return([o1.price, o2.price, o3.price, o4.price,
                                      o5.price, o6.price, o7.price, o8.price]) }

        before { Order.should_receive(:flag_outliers)
                         .with(t1.type_id, r1.region_id, [31.0, 52.0])
                         .and_return(2) }

        specify { Order.update_outliers.should == 2 }
      end

      context "without enough orders" do
        before { Order.stub_chain(:active, :where, :pluck)
                         .and_return([o1.price, o2.price, o3.price]) }
#        before { Order.stub_chain(:active, :where).and_return([o1, o2, o3]) }

        before { Order.should_not_receive(:flag_outliers) }

        specify { Order.update_outliers.should == 0 }
      end
    end
  end
end
