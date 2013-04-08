require 'spec_helper.rb'

describe OrderStat do
  let(:type_id) { 34 }
  let(:r1) { FactoryGirl.create(:region, :region_id => 10000002, :has_hub => true) }
  let(:t1) { FactoryGirl.create(:type, :type_id => type_id) }

  let(:type1) { double('type', id: 34) }
  let(:type2) { double('type', id: 35) }


  describe "sim_xact" do
    context "buying with enough orders" do
      before {
        FactoryGirl.create(:sell_order, :issued => 1.month.ago, :duration => 1,
                           :type => t1, :region => r1, :price => 9,
                           :vol_enter => 100, :vol_remain => 100)
        FactoryGirl.create(:sell_order, :type => t1, :region => r1, :price => 49,
                           :vol_enter => 100, :vol_remain => 100)
        FactoryGirl.create(:sell_order, :type => t1, :region => r1, :price => 52,
                           :vol_enter => 100000, :vol_remain => 100000)
        FactoryGirl.create(:sell_order, :type => t1, :region => r1, :price => 50,
                           :vol_enter => 100, :vol_remain => 100)
        FactoryGirl.create(:buy_order, :type => t1, :region => r1, :price => 1,
                           :vol_enter => 100, :vol_remain => 100)
      }

      let(:orders) { Order }

      specify {
        orders.count.should == 5
        OrderStat.sim_buy(orders, 0.05).should == 51.90
      }
    end

    context "selling with enough orders" do
      before {
        FactoryGirl.create(:buy_order, :issued => 1.month.ago, :duration => 1,
                           :type => t1, :region => r1, :price => 9,
                           :vol_enter => 100, :vol_remain => 100)
        FactoryGirl.create(:buy_order, :type => t1, :region => r1, :price => 49,
                           :vol_enter => 100, :vol_remain => 100)
        FactoryGirl.create(:buy_order, :type => t1, :region => r1, :price => 9,
                           :vol_enter => 100000, :vol_remain => 100000)
        FactoryGirl.create(:buy_order, :type => t1, :region => r1, :price => 50,
                           :vol_enter => 100, :vol_remain => 100)
        FactoryGirl.create(:sell_order, :type => t1, :region => r1, :price => 1,
                           :vol_enter => 100, :vol_remain => 100)
      }

      let(:orders) { Order }

      specify {
        orders.count.should == 5
        OrderStat.sim_sell(orders, 0.05).should == 10.62
      }
    end

    context "not enough orders" do
      let!(:o1) { FactoryGirl.create(:sell_order, :vol_remain => 1) }
      let(:orders) { Order }

      specify {
        Order.count.should == 1
        OrderStat.sim_buy(orders, 0.05).should be_nil
      }
    end
  end

  describe "stats" do
    let(:the_time) { Time.now }

    let(:time) { double('time', now: the_time) }

    before { OrderStat.stub(:latest_reported).and_return(the_time.utc) }

    let(:price_data) { [{:price => 1, :vol => 100}, {:price => 10, :vol => 2},
                        {:price => 100, :vol => 10}, {:price => 1000, :vol => 1}] }

    let(:type_stats) { {:max_buy => 47.0, :buy_vol => 2075, :min_sell => 48.0,
                        :sell_vol => 1120, :sim_buy => 49.01, :sim_sell => 44.7,
                        :median => 47.5, :ts => the_time.utc, :mid_buy_sell => 47.5,
                        :type_id => 34, :region_id => 10000002} }

    let!(:bo1) { FactoryGirl.create(:buy_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 2000, :price => 42) }
    let!(:bo2) { FactoryGirl.create(:buy_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 150, :price => 1) }
    let!(:bo3) { FactoryGirl.create(:buy_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 25, :price => 47) }
    let!(:bo4) { FactoryGirl.create(:buy_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 25, :price => 46) }
    let!(:bo5) { FactoryGirl.create(:buy_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 25, :price => 45) }

    let!(:so1) { FactoryGirl.create(:sell_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 1500, :price => 95) }
    let!(:so2) { FactoryGirl.create(:sell_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 1000, :price => 50) }
    let!(:so3) { FactoryGirl.create(:sell_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 100, :price => 49) }
    let!(:so4) { FactoryGirl.create(:sell_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 10, :price => 48) }
    let!(:so5) { FactoryGirl.create(:sell_order, :type_id => type_id, :region => r1,
                                    :vol_enter => 5000, :vol_remain => 10, :price => 49) }

    describe "region stats" do
      let(:order_list) { double(:sell  => [so1, so2, so3, so4, so5],
                                :buy   => [bo1, bo2, bo3, bo4, bo5],
                                :count => 10) }
      subject { OrderStat.build_region_stats(r1, t1) }

      specify {
        subject[:median].should == 47.5

        subject[:min_sell].should == 48
        subject[:max_buy].should == 47

        subject[:sim_buy].should == 49.01
        subject[:sim_sell].should == 44.7

        subject[:sell_vol].should == 1120
        subject[:buy_vol].should == 2075

        subject[:mid_buy_sell].should == 47.5
      }
    end

    describe "extracting prices from price data" do
      specify { OrderStat.send(:extract_prices, price_data).should == [1, 10, 100, 1000] }
    end

    describe "finding the mid buy/sell price from the generated stats" do
      let(:stats) { {:max_buy => 55, :min_sell => 100} }
      specify { OrderStat.send(:mid_buy_sell, stats).should == 77.5 }
    end

    describe "filtering outliers from price data" do
      let(:filtered) { [{:price => 1, :vol => 100},
                        {:price => 10, :vol => 2},
                        {:price => 100, :vol => 10}] }
      specify { OrderStat.send(:filter_outliers, price_data).should == filtered }
    end

    describe "totaling volumes related to non-outlining prices" do
      specify { OrderStat.send(:filtered_vol, price_data).should == 112 }
    end

    describe "stats for a type" do
      before { OrderStat.stub(:build_types).and_return([t1]) }
      let(:hubs_stats) { type_stats.dup.delete_if { |k,v| k == :region_id } }

      specify { OrderStat.build_type_stats(type_id).should == [type_stats, hubs_stats] }
    end

    describe "building a list of types" do
      context "with a type given" do
        before { Type.should_receive(:find).with(type1.id).and_return(type1) }

        specify { OrderStat.send(:build_types, type1.id).should == [type1] }
      end

      context "with no type given" do
        before { OrderStat.should_receive(:mkt_types).and_return([type1, type2]) }

        specify { OrderStat.send(:build_types).should == [type1, type2] }
      end
    end

    describe "extracing price data from orders price data" do
      let(:orders) { Order.all }

      subject { OrderStat.price_data(orders) }

      specify {
        subject[:buy].should have(5).things
        subject[:buy].first.should == {:price=>42.0, :vol=>2000}

        subject[:sell].should have(5).things
        subject[:sell].first.should == {:price=>95.0, :vol=>1500}
      }
    end

    describe "saving stats" do
      let(:stats) { [{max_buy: 6.0, buy_vol: 1234, min_sell: 5.75,
                      sell_vol: 2345, sim_buy: 5.89, sim_sell: 5.94,
                      median: 5.95, type_id: 34, ts: Time.now}] }
      before { OrderStat.save_stats(stats) }

      specify { OrderStat.count.should == 1 }
    end

    describe "stats for all types" do
      let(:mkt_types) { [type1, type2] }
      before { OrderStat.stub(:mkt_types).and_return(mkt_types) }
      before { OrderStat.stub(:last_stat).and_return(1.hour.ago) }
      before { OrderStat.should_receive(:build_type_stats)
                            .with(type1.id, nil)
                            .and_return([type_stats]) }
      before { OrderStat.should_receive(:build_type_stats)
                            .with(type2.id, nil)
                            .and_return([type_stats]) }
      before { OrderStat.should_receive(:save_stats)
                            .with([type_stats])
                            .twice
                            .and_return(true) }

      specify { OrderStat.build_all }
    end
  end

  describe "mineral hub stats" do
    let(:t1) { FactoryGirl.build(:type, type_id: 34, name: 'A') }
    let(:t2) { FactoryGirl.build(:type, type_id: 35, name: 'B') }

    before { Region.stub(:hub_region_ids).and_return([1,2]) }
    before { MarketGroup.stub(:minerals).and_return([t1, t2]) }

    let!(:os1) { FactoryGirl.create(:order_stat, type_id: t1.type_id,
                                     region_id: 1, ts: 1.day.ago) }
    let!(:os2) { FactoryGirl.create(:order_stat, type_id: t2.type_id,
                                     region_id: 1, ts: 1.week.ago) }
    let!(:os3) { FactoryGirl.create(:order_stat, type_id: t1.type_id,
                                     region_id: 2, ts: 1.week.ago) }

    let(:stats) { OrderStat.minerals_for_hubs }

    specify { stats.should have(2).things }
    specify { stats['A'].should have(2).things }
    specify { stats['A'][1].should == os1 }
    specify { stats['A'][2].should == os3 }
    specify { stats['B'].should have(1).thing }
    specify { stats['B'][1].should == os2 }

  end

  describe "region stats" do
    context "type found, recent" do
      let!(:os1) { FactoryGirl.create(:order_stat, type_id: type_id,
                                       region: r1, ts: 1.day.ago) }
      let!(:os2) { FactoryGirl.create(:order_stat, type_id: type_id,
                                       region: r1, ts: 1.week.ago) }
      let(:stats) { OrderStat.region_stats(34) }

      specify { stats.should have(1).thing }
      specify { stats[r1.name].type_id.should == type_id }
      specify { stats[r1.name].region_id.should == r1.id }
      specify { stats[r1.name].should == os1 }
    end

    context "type found, old" do
      let!(:os) { FactoryGirl.create(:order_stat, type_id: type_id,
                                       region: r1, ts: 1.year.ago) }
      specify { OrderStat.region_stats(34).should == {} }
    end

    context "type not found" do
      specify { OrderStat.region_stats(35).should == {} }
    end
  end
end
