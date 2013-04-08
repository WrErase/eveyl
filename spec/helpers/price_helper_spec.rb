require 'spec_helper'

describe PriceHelper do
  describe "formatting a price" do
    specify { format_price(1).should == '1' }
    specify { format_price(1.0).should == '1' }
    specify { format_price(1.1).should == '1.10' }
    specify { format_price(1_000_000).should == '1,000,000' }
    specify { format_price(1_000_000.0).should == '1,000,000' }
    specify { format_price(1_000_000, true).should == '1,000,000' }
    specify { format_price(1_000_000.01, true).should == '1,000,000' }
  end
end
