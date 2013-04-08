require 'spec_helper'

describe BillOfMaterials do
  let(:bp) { double('blueprint') }
  let(:bill) { BillOfMaterials.new(bp: bp) }

  describe "calculating the material multiplier" do
    context "with negative me" do
      before { bill.stub(:me).and_return(-4) }
      before { bill.stub(:pe).and_return(5) }

      specify { bill.material_multiplier.should == 1.5 }
    end

    context "with positive me" do
      before { bill.stub(:me).and_return(1) }
      before { bill.stub(:pe).and_return(5) }

      specify { bill.material_multiplier.should == 1.05 }
    end
  end

  describe "getting base materials" do
    let(:materials) { double('materials', includes: 'mat') }

    context "has a blueprint type" do
      let(:bp_type) { double('blueprint_type', materials: materials) }
      before { bp.stub(:blueprint_type).and_return(:bp_type) }
      before { bill.stub(:bp).and_return(nil) }
    end

    context "is a blueprint type" do
      before { bp.stub(:materials).and_return(materials) }
      specify { bill.base_materials.should == 'mat' }
    end
  end

  describe "building base materials" do
    let!(:mat_type) { FactoryGirl.build(:type, type_id: 3, group_id: 5) }
    before { mat.stub(:type).and_return(mat_type) }
    before { mat_type.stub(:category_name).and_return('Cat1') }

    let!(:mat) { TypeMaterial.new(type_id: 2, quantity: 2,
                                  material_type_id: 3) }

    before { bill.stub(:base_materials).and_return([mat]) }

    specify { bill.build_base_materials.count.should == 1 }
    specify { bill.build_base_materials.first.name.should == mat.type_name }
    specify { bill.build_base_materials.first.type_id.should == 3 }
    specify { bill.build_base_materials.first.base.should == 2 }
    specify { bill.build_base_materials.first.category.should == 'Cat1' }
  end

  describe "subtracting recycled" do
    let(:req1) { double('requirement', recycle: true) }
    let(:req2) { double('requirement', recycle: false) }

    let(:rm_mat) { double(:material, material_type_id: 5, quantity: 8) }
    before { req1.stub_chain(:required_type, :materials).and_return([rm_mat]) }

    let(:mat) { OpenStruct.new(type_id: 5, base: 10) }
    before { bp.stub(:mfg_requirements).and_return([req1, req2]) }

    before { bill.subtract_recycled([mat]) }

    specify { mat.base.should == 2 }
  end

  describe "adding additional materials" do
    let(:req1) { double('requirement', required_type_name: 'name',
                                       required_type_id: 5,
                                       quantity: 10,
                                       damage_per_job: 1.0) }

    before { bp.stub(:mfg_requirements).and_return([req1]) }
    let(:mats) { [mat] }

    context "incrementing a requirement" do
      let(:mat) { OpenStruct.new(type_id: 5, needed: 11, base: 10) }

      before { bill.add_additional_materials(mats) }

      specify { mats.count.should == 1 }
      specify { mats.last.base.should == 20 }
      specify { mats.last.needed.should == 21 }
    end

    context "adding a requirement" do
      before { req1.stub_chain(:required_type, :category_name).and_return('cat_name') }
      let(:mat) { OpenStruct.new(type_id: 9, needed: 11, base: 10) }

      before { bill.add_additional_materials(mats) }

      specify { mats.count.should == 2 }
      specify { mats.last.name.should == 'name' }
      specify { mats.last.base.should == 10 }
      specify { mats.last.needed.should == 10 }
    end
  end
end
