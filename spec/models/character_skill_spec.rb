require 'spec_helper'

describe CharacterSkill do
  describe "updating from api" do
    let(:result) { double('result', typeID: '3431', skillpoints: '8000',
                                    level: '3', published: '1') }

    before { CharacterSkill.update_from_api(12 ,result) }

    specify { CharacterSkill.count.should == 1 }
    specify { CharacterSkill.first.character_id.should == 12 }
    specify { CharacterSkill.first.type_id.should == 3431 }
    specify { CharacterSkill.first.skill_points.should == 8000 }
    specify { CharacterSkill.first.level.should == 3 }
    specify { CharacterSkill.first.published.should be_true }
  end

  describe "finding by name" do
    let!(:skill) { FactoryGirl.create(:character_skill, type_id: 100) }
    let!(:type) { FactoryGirl.create(:type, type_id: 100, name: 'skill1') }

    specify { CharacterSkill.find_by_name('skill1').should == skill }
  end

#  def self.group_by_type(character_id)
#        includes(:type, :group).where(character_id: character_id).group_by(&:group_name)
  describe "grouping by type" do
    let!(:skill) { FactoryGirl.create(:character_skill, type_id: 100,
                                            character_id: 10) }
    let!(:type) { FactoryGirl.create(:type, type_id: 100, group_id: 20, name: 'skill1') }
    let!(:group) { FactoryGirl.create(:group, group_id: 20, name: 'group1') }

    specify { CharacterSkill.group_by_type(10).should == {"group1" => [skill]} }
  end
end
