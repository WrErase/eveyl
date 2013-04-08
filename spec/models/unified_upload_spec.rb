require 'spec_helper'

describe UnifiedUpload do
  describe "with order data" do
    # Only the first rowset item is considered valid
    let(:order_data_json) { %Q{
       {"resultType" : "orders",
        "version" : "0.1",
        "uploadKeys" : [
          { "name" : "emk", "key" : "abc" },
          { "name" : "ec" , "key" : "def" }
        ],
        "generator" : { "name" : "Yapeal", "version" : "11.335.1737" },
        "currentTime" : "2011-10-22T15:46:00+00:00",
        "columns" : ["price","volRemaining","range","orderID","volEntered","minVolume","bid","issueDate","duration","stationID","solarSystemID"],
        "rowsets" : [
          {
            "generatedAt" : "2011-10-22T15:43:00+00:00",
            "regionID" : 10000065,
            "typeID" : 11134,
            "rows" : [
              [8999,1,32767,2363806077,1,1,false,"2011-12-03T08:10:59+00:00",90,60008692,30005038],
              [11499.99,10,32767,2363915657,10,1,false,"2011-12-03T10:53:26+00:00",90,60006970,null],
              [11500,48,32767,2363413004,50,1,false,"2011-12-02T22:44:01+00:00",90,60006967,30005039]
            ]
          },
          {
            "generatedAt" : "2011-10-22T15:42:00+00:00",
            "regionID" : null,
            "typeID" : 11135,
            "rows" : [
              [8999,1,32767,2363806077,1,1,false,"2011-12-03T08:10:59+00:00",90,60008692,30005038],
              [11499.99,10,32767,2363915657,10,1,false,"2011-12-03T10:53:26+00:00",90,60006970,null],
              [11500,48,32767,2363413004,50,1,false,"2011-12-02T22:44:01+00:00",90,60006967,30005039]
            ]
          },
          {
            "generatedAt" : "2011-10-22T15:43:00+00:00",
            "regionID" : 10000065,
            "typeID" : 11136,
            "rows" : []
          }
        ]
      }
    } }

    let(:order_data) { JSON.parse(order_data_json) }

    subject { UnifiedUpload.build_upload(order_data) }

    let(:sample_rowset) { order_data['rowsets'].first }
    let(:sample_row) { sample_rowset['rows'].first }

    describe "remapping the columns" do
      let(:remapped) { [:price, :vol_remain, :range, :order_id, :vol_enter,
                        :min_vol, :bid, :issued, :duration, :station_id,
                        :solar_system_id] }

      specify { subject.remap_model_columns(order_data['columns']).should == remapped }
    end

    describe "parsing the metadata" do
      before { subject.parse_metadata(order_data) }

      specify { subject.result_type.should == "orders" }
      specify { subject.version.should == "0.1" }
      specify { subject.gen_name.should == "Yapeal" }
      specify { subject.gen_version.should == "11.335.1737" }
      specify { subject.upload_keys.should == [{"name"=>"emk", "key"=>"abc"}, {"name"=>"ec", "key"=>"def"}] }
    end

    describe "mapping the data rows" do
      let(:response) {{:bid => false, :duration => 90, :gen_name => 'Yapeal',
                       :gen_version => '11.335.1737',
                       :issued => "2011-12-03T08:10:59+00:00",
                       :min_vol => 1, :order_id => 2363806077, :price => 8999,
                       :range => 32767, :region_id => 10000065,
                       :reported_ts => '2011-10-22T15:43:00+00:00',
                       :solar_system_id => 30005038, :station_id => 60008692,
                       :type_id => 11134, :vol_enter => 1, :vol_remain => 1 } }

      specify { subject.map_row(sample_row, sample_rowset).should == response }
    end

    describe "parsing the rowset" do
      specify { subject.parse_rowset(sample_rowset).should have(3).things }
      specify { subject.parse_rowset(sample_rowset).first.should have(16).things }
    end

    describe "parsing the full data set" do
      context "valid data" do
        before { subject.parse_data(order_data) }

        specify { subject.rows.should have(3).things }
      end

      context "invalid generator" do
        before { order_data["generator"] = {"name" => nil, "version" => nil } }

        specify { lambda { subject.parse_data(order_data)}.should raise_error(InvalidGenerator) }
      end

      context "relayed data" do
        before { order_data["uploadKeys"] = [ {"name" => "emk", "key" => "RELAYED"} ] }

        specify { lambda { subject.parse_data(order_data)}.should raise_error(RelayedUpload) }
      end
    end

    describe "saving rows" do
      before { Order.stub(:save_if_new).and_return(ret) }

      context "order that's valid" do
        let(:ret) { double('order', 'valid?' => true) }

        specify { subject.save_rows.should == 3 }
      end

      context "order with an error" do
        let(:ret) { double('order', 'valid?' => false) }

        specify { subject.save_rows.should == 0 }
      end
    end
  end

  describe "history data" do
    let(:history_data_json) { %Q{
        {
          "resultType" : "history",
          "version" : "0.1",
          "uploadKeys" : [
            { "name" : "emk", "key" : "abc" },
            { "name" : "ec" , "key" : "def" }
          ],
          "generator" : { "name" : "Yapeal", "version" : "11.335.1737" },
          "currentTime" : "2011-10-22T15:46:00+00:00",
          "columns" : ["date","orders","quantity","low","high","average"],
          "rowsets" : [
            {
              "generatedAt" : "2011-10-22T15:42:00+00:00",
              "regionID" : 10000065,
              "typeID" : 11134,
              "rows" : [
                ["2011-12-03T00:00:00+00:00",40,40,1999,499999.99,35223.50],
                ["2011-12-02T00:00:00+00:00",83,252,9999,11550,11550]
              ]
            }
          ]
        }
    } }

    let(:history_data) { JSON.parse(history_data_json) }

    subject { UnifiedUpload.build_upload(history_data) }

    let(:sample_rowset) { history_data['rowsets'].first }
    let(:sample_row) { sample_rowset['rows'].first }

    describe "remapping the columns" do
      let(:remapped) { [:ts, :orders, :quantity, :low, :high, :average] }

      specify { subject.remap_model_columns(history_data['columns']).should == remapped }
    end

    describe "parsing the metadata" do
      before { subject.parse_metadata(history_data) }

      specify { subject.result_type.should == "history" }
      specify { subject.version.should == "0.1" }
      specify { subject.gen_name.should == "Yapeal" }
      specify { subject.gen_version.should == "11.335.1737" }
      specify { subject.upload_keys.should == [{"name"=>"emk", "key"=>"abc"}, {"name"=>"ec", "key"=>"def"}] }
    end

    describe "mapping the data rows" do
      let(:response) { {:ts => "2011-12-03T00:00:00+00:00", :orders => 40,
                        :quantity => 40, :low => 1999, :high => 499999.99,
                        :average => 35223.5, :region_id => 10000065,
                        :type_id => 11134, :gen_name => "Yapeal",
                        :gen_version => "11.335.1737",
                        :reported_ts=> "2011-10-22T15:42:00+00:00"} }

      specify { subject.map_row(sample_row, sample_rowset).should == response }
    end

    describe "saving rows" do
      before { OrderHistory.stub(:create).and_return(ret) }

      context "order that's valid" do
        let(:ret) { double('order_history', 'valid?' => true) }

        specify { subject.save_rows.should == 2 }
      end

      context "order with an error" do
        let(:ret) { double('order_history', 'valid?' => false) }

        specify { subject.save_rows.should == 0 }
      end
    end

#    describe "saving order rows" do
#      let(:order) { FactoryGirl.build(:buy_order) }
#      let(:rows) { [order] }
#
#      before { subject.should_receive(:save_if_new).and_return(order) }
#      before { subject.send(:save_order_rows, rows).should == 1 }
#
#      specify { Order.count.should == 1 }
#      specify { Order.first.should == order }
#    end
#
#    describe "saving history rows" do
#    end
  end
end
