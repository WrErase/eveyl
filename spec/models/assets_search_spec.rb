require 'spec_helper'

describe AssetsSearch do
  let(:search) { AssetsSearch.new(character_ids: [1,2]) }

  describe "search type" do
    context "no query" do
      specify { search.search_is_type?.should be_false }
      specify { search.search_is_material?.should be_false }
    end

    context "is a type" do
      let(:search) { AssetsSearch.new(query: '1234') }
      specify { search.search_is_type?.should be_true }
    end

    context "is not a type" do
      let(:search) { AssetsSearch.new(query: '1') }
      specify { search.search_is_type?.should be_false }
    end

    context "is a material" do
      let(:search) { AssetsSearch.new(query: 'Material') }
      specify { search.search_is_material?.should be_true }
    end
  end

  describe "building a query" do
    let(:t1) { FactoryGirl.create(:type, name: 'DEF') }
    let(:t2) { FactoryGirl.create(:type, name: 'ABC') }
    let!(:ch1) { FactoryGirl.create(:character_asset, type: t1, character_id: 1) }
    let!(:ch2) { FactoryGirl.create(:character_asset, type: t2, character_id: 2) }

    context "with a type id search" do
      context "no matches for the chars" do
        let(:search) { AssetsSearch.new(character_ids: [2],
                                        query: t1.id.to_s) }
        specify { search.build_query.should be_empty }
      end

      context "matches" do
        let(:search) { AssetsSearch.new(character_ids: [1,2],
                                        query: t1.id.to_s) }
        specify { search.build_query.should == [ch1] }
      end
    end

    context "with a type name search" do
      context "no matches for the chars" do
        let(:search) { AssetsSearch.new(character_ids: [2],
                                        query: 'de') }
        specify { search.build_query.should be_empty }
      end

      context "matches" do
        let(:search) { AssetsSearch.new(character_ids: [1,2],
                                        query: 'de') }
        specify { search.build_query.should == [ch1] }
      end
    end

    context "without a search" do
      specify { search.build_query.should == [ch2, ch1] }
    end
  end
end
