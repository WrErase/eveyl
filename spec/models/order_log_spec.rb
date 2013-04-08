require 'spec_helper'

describe OrderLog do
  context "without an existing log" do
    let(:order) { FactoryGirl.build(:buy_order) }

    before { OrderLog.log_order(order) }

    let(:log) { OrderLog.first }

    specify { log.should_not be_nil }
    specify { log.order_id.should == order.id }
    specify { log.price.should == order.price }
    specify { log.vol_remain.should == order.vol_remain }
    specify { log.gen_name.should == order.gen_name }
    specify { log.gen_version.should == order.gen_version }
    specify { log.reported_ts.round(2).should == order.reported_ts.round(2) }
  end

  context "with an existing log" do
    let(:order) { FactoryGirl.build(:buy_order) }

    before { OrderLog.log_order(order) }

    specify { OrderLog.log_order(order).should be_false }
  end
end
