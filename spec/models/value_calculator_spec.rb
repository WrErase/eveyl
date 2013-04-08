require 'spec_helper'

describe ValueCalculator do
  let(:item) { double('item', type_id: 1, portion_size: 1) }

  let(:stats) { double('stats', median: 100.12) }

  let(:vc) { ValueCalculator.new(region_id: 234,
                                 stat_type: :median) }

  describe "calculating an item's value" do
    before { OrderStat.should_receive(:latest_stat)
                      .once
                      .with(1, 234)
                      .and_return(stats) }

    context "no cache" do
      specify { vc.value(item).should == 100.12 }
    end

    context "cached" do
      before { vc.value(item) }
      before { OrderStat.should_not_receive(:latest_stat) }

      specify { vc.value(item).should == 100.12 }
    end
  end

  describe "calculating an item's material value" do
    let(:mats) { [double('material', quantity: 1, material_type_id: 2),
                  double('material', quantity: 2, material_type_id: 3)] }

    before { item.should_receive(:materials)
                 .once
                 .and_return(mats) }

    before { vc.should_receive(:value_by_type_id)
                .once
                .with(2)
                .and_return(100.12) }

    before { vc.should_receive(:value_by_type_id)
                .once
                .with(3)
                .and_return(50.10) }

    context "no cache" do
      specify { vc.mat_value(item).should == 200.32 }
    end

    context "cached" do
      before { vc.mat_value(item) }
      before { vc.should_not_receive(:value_by_type_id) }

      specify { vc.mat_value(item).should == 200.32 }
    end
  end

  describe "building values" do
    let(:calc) { ValueCalculator.new(region_id: 10000002,
                                     stat_type: :stat1) }

    context "success" do
      before { calc.should_receive(:value_by_type_id)
                   .with(34)
                   .and_return(99.2) }

      before { calc.should_receive(:mat_value_by_type_id)
                   .with(34)
                   .and_return(96.1) }

      before { ValueCalculator.build_values_with_calc(calc, 34) }

      specify { TypeValue.count.should == 1 }
      specify { TypeValue.first.type_id.should == 34 }
      specify { TypeValue.first.region_id.should == 10000002 }
      specify { TypeValue.first.value.should == 99.2 }
      specify { TypeValue.first.mat_value.should == 96.1 }
    end

    context "mat_value failure" do
      before { calc.should_receive(:value_by_type_id)
                   .with(34)
                   .and_return(99.2) }

      before { calc.should_receive(:mat_value_by_type_id)
                   .with(34)
                   .and_raise(ValueCalculator::NoStatForRegion) }

      before { ValueCalculator.build_values_with_calc(calc, 34) }

      specify { TypeValue.count.should == 1 }
      specify { TypeValue.first.type_id.should == 34 }
      specify { TypeValue.first.region_id.should == 10000002 }
      specify { TypeValue.first.value.should == 99.2 }
      specify { TypeValue.first.mat_value.should be_nil }
    end

    context "value failure" do
      before { calc.should_receive(:value_by_type_id)
                   .with(34)
                   .and_raise(ValueCalculator::NoStatForRegion) }

      before { ValueCalculator.build_values_with_calc(calc, 34) }

      specify { TypeValue.count.should == 0 }
    end

  end

  describe "building values" do
    before { Region.stub(:pluck).and_return([10000002]) }
    before { OrderStat.stub(:value_stats).and_return([:stat1]) }

    context "with a type" do
      before { ValueCalculator.should_receive(:build_values_with_calc)
                              .with(anything(), 34) }
      specify { ValueCalculator.build_values(34) }
    end

    context "without a type" do
      before { Type.stub_chain(:on_market, :pluck).and_return([34, 35]) }
      before { ValueCalculator.should_receive(:build_values_with_calc)
                              .with(anything(), 34) }
      before { ValueCalculator.should_receive(:build_values_with_calc)
                              .with(anything(), 35) }

      specify { ValueCalculator.build_values }
    end
  end
end
