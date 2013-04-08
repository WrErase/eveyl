require 'spec_helper'

describe EveCentralDump do
  let(:column_map) { {0=>:order_id, 1=>:region_id, 2=>:solar_system_id, 3=>:station_id,
                      4=>:type_id, 5=>:bid, 6=>:price, 7=>:min_vol, 8=>:vol_remain,
                      9=>:vol_enter, 10=>:issued, 11=>:duration, 12=>:range, 14=>:reported_ts} }

  let(:row) { ["2483405487","10000043","30002187","60008494","16690","0","2063998.52",
               "1","5","15","2012-05-18 05:14:14","90 days, 0:00:00","32767","0",
               "2012-06-19 06:05:10.489723"] }

  let(:header) { ["orderid","regionid","systemid","stationid","typeid",
                  "bid","price","minvolume","volremain","volenter",
                  "issued","duration","range","reportedby","reportedtime"] }

  let(:remap) { {:order_id=>2483405487, :region_id=>10000043, :solar_system_id=>30002187,
                 :station_id=>60008494, :type_id=>16690, :bid=>0, :price=>2063998.52,
                 :min_vol=>1, :vol_remain=>5, :vol_enter=>15, :issued=>Time.parse('2012-05-18 05:14:14 UTC'),
                 :duration=>90, :range=>32767, :reported_ts=>Time.parse('2012-06-19 06:05:10.489723 UTC')} }

  describe "header parsing with a valid header" do

    subject { EveCentralDump.new }

    specify { subject.parse_headings(header).should == column_map }
  end

  describe "header parsing with an empty header" do
    let(:header) { [] }

    subject { EveCentralDump.new }

    specify { lambda { subject.parse_headings(header)}.should raise_error(EveCentralDump::MalformedHeader) }
  end

  describe "cleaning a row" do
    context "valid row" do
      let(:cleaned) { [2483405487, 10000043, 30002187, 60008494, 16690, 0, 2063998.52,
                       1, 5, 15, Time.parse('2012-05-18 05:14:14 UTC'), 90, 32767, "0",
                       Time.parse('2012-06-19 06:05:10.489723 UTC')] }

      specify { subject.clean_row(row, column_map).should == cleaned }
    end

    context "malformed row" do
      before { row[-1] = '2012-06-1906:05:10.489723' }

      specify { lambda { subject.clean_row(row, column_map)}.should raise_error }
    end
  end

  describe "remapping a row" do
    specify { subject.send(:remap_row, row, column_map).should == remap }
  end

  describe "loading the heading" do
    before { subject.should_receive(:file_heading).with('dummy').and_return( header.join(',') ) }

    specify { subject.load_headings('dummy').should == column_map }
  end

  describe "parsing the duration" do
    specify { subject.duration_to_days('4 days').should == 4 }
    specify { subject.duration_to_days('4').should == 4 }
    specify { subject.duration_to_days('').should be_nil }
    specify { subject.duration_to_days('1 hour').should be_nil }
  end

  describe "saving a row" do
    let(:update) { remap.merge({:gen_name => 'Eve Market Dump'}) }
    before { Order.should_receive(:save_if_new).with(update).and_return(true) }
    specify { subject.save_row(remap).should be_true }
  end

  describe "outputing run time" do
    context "from a time" do
      specify { subject.send(:run_time, 2.hours.ago).should == '2.0 h' }
      specify { subject.send(:run_time, 2.minutes.ago).should == '2.0 m' }
      specify { subject.send(:run_time, 2.seconds.ago).should == '2 s' }
    end
    context "from a unix timestamp" do
      specify { subject.send(:run_time, 2.hours.ago.to_f).should == '2.0 h' }
      specify { subject.send(:run_time, 2.minutes.ago.to_f).should == '2.0 m' }
      specify { subject.send(:run_time, 2.seconds.ago.to_f).should == '2 s' }
    end
  end

  describe "validating the file" do
    context "nil file" do
      specify { lambda { subject.validate_file('')}.should raise_error }
    end
    context "missing file" do
      before { File.stub(:exists?).and_return(false) }
      specify { lambda { subject.validate_file('dummy')}.should raise_error }
    end
    context "unreadable file" do
      before { File.stub(:exists?).and_return(true) }
      before { File.stub(:readable?).and_return(false) }
      specify { lambda { subject.validate_file('dummy')}.should raise_error }
    end
    context "file too short" do
      before { File.stub(:exists?).and_return(true) }
      before { File.stub(:readable?).and_return(true) }
      before { subject.stub(:file_lines).and_return(1) }
      specify { lambda {subject.validate_file('dummy')}.should raise_error }
    end
  end

  describe "loading a file" do
    let(:file) { 'dummy.dump' }
    before { subject.should_receive(:validate_file).with(file).and_return(true) }
    before { subject.should_receive(:load_headings).with(file).and_return(column_map) }

    context "less lines than batch size" do
      subject { EveCentralDump.new(:batch_size => 10) }

      before { subject.stub(:file_lines).and_return(2) }
      before { CSV.should_receive(:foreach).and_yield(header).and_yield(row) }

      before { subject.should_receive(:save_row).with(remap).and_return(true) }

      specify { subject.load_file(file) }
    end

    context "more lines than batch size" do
      subject { EveCentralDump.new(:batch_size => 1) }

      before { subject.should_receive(:file_lines).with(file).and_return(3) }
      before { CSV.should_receive(:foreach).and_yield(header).and_yield(row).and_yield(row) }

      before { subject.should_receive(:save_row).twice.with(remap).and_return(true) }

      specify { subject.load_file(file) }
    end
  end
end
