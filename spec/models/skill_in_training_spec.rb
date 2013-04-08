require 'spec_helper'

describe SkillInTraining do
  let(:attr) { double('attribute_type', name: 'skill1', value_int: 2) }
  let(:type) { FactoryGirl.create(:type, type_id: 1) }
  let(:skill) { SkillInTraining.new(skill_type: type) }

  describe "attributes" do
    before { AttributeType.should_receive(:find)
                          .with(2)
                          .and_return(attr) }

    describe "primary attribute" do
      before { type.should_receive(:find_attribute_by_name)
                   .with('primaryAttribute')
                   .and_return(attr) }
      specify { skill.primary_attribute.should == 'skill1' }
    end

    describe "secondary attribute" do
      before { type.should_receive(:find_attribute_by_name)
                   .with('secondaryAttribute')
                   .and_return(attr) }
      specify { skill.secondary_attribute.should == 'skill1' }
    end
  end

  describe "sp rate" do
    before { skill.stub(:primary_attribute).and_return(:pri) }
    before { skill.stub(:secondary_attribute).and_return(:sec) }

    let(:character) { double('character', pri: 20, sec: 24) }

    specify { skill.sp_rate_min(character).should == (32 * 60) }
  end
end
