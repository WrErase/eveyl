require 'spec_helper'

describe SolarSystem do
  let!(:s1) { FactoryGirl.create(:solar_system, name: 'ABC') }
  let!(:s2) { FactoryGirl.create(:solar_system, name: 'DEF') }

  describe "getting ids" do
    specify { SolarSystem.ids.should == [s1.id, s2.id] }
  end

  describe "finding by name" do
    specify { SolarSystem.by_name('EF').should == [s2] }
  end

  describe "getting names" do
    context "query" do
      specify { SolarSystem.names.map(&:name) == [s1.name, s2.name] }
    end

    context "no query" do
      specify { SolarSystem.names('EF').map(&:name) == [s2.name] }
    end
  end

  describe "dotlan url" do
    let(:url) { "http://evemaps.dotlan.net/system/The_Forge" }
    before { s1.name = 'The Forge' }

    specify { s1.dotlan_url.should == url }
  end
end
