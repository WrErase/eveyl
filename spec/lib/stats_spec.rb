require 'spec_helper.rb'

describe Stats do
  describe "median" do
    context "odd number of vals" do
      let(:vals) { [9, 3, 44, 17, 15] }
      specify { vals.median.should == 15 }
    end

    context "even number of vals" do
      let(:vals) { [8, 3, 44, 17, 12, 6] }
      specify { vals.median.should == 10 }
    end
  end

  describe "mean" do
    let(:vals) { [15, 18, 22, 20] }
    specify { vals.mean.should == 18.75 }
  end

  describe "stdev" do
    let(:vals) { [2, 4, 4, 4, 5, 5, 7, 9] }
    specify { vals.stdev.should == 2 }
  end

  describe "percentile" do
    let(:vals) { [6, 147, 49, 15, 42, 41, -70, 39, 43, 40, 36] }

    specify { vals.percentile(0.25).should == 15 }
    specify { vals.percentile(0.75).should == 43 }
  end

  describe "get_inner_fences" do
    let(:vals) { [6, 147, 49, 15, 42, 41, -70, 39, 43, 40, 36] }

    specify { vals.get_inner_fences.should == [-27.0, 85.0] }
  end

  describe "get_outer_fences" do
    let(:vals) { [6, 147, 49, 15, 42, 41, -70, 39, 43, 40, 36] }

    specify { vals.get_outer_fences.should == [-69, 127] }
  end

  describe "find outliers" do
    let(:vals) { [6, 147, 49, 15, 42, 41, -70, 39, 43, 40, 36] }

    specify { vals.find_outliers.should == [147, -70] }
    specify { vals.should have(11).things }
  end

  describe "prune_outliers" do
    let(:vals) { [6, 147, 49, 15, 42, 41, -70, 39, 43, 40, 36] }

    specify { vals.prune_outliers!.should == [6, 49, 15, 42, 41, 39, 43, 40, 36] }
  end

end
