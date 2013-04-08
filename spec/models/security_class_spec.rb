require 'spec_helper'

describe SecurityClass do
  describe "getting security class" do
    specify { SecurityClass.get_trusec('A').should == Range.new(0.95, 1.00) }
    specify { SecurityClass.get_trusec('B1').should == Range.new(0.45, 0.75) }
    specify { SecurityClass.get_trusec('E1').should == Range.new(0.00, 0.25) }
    specify { SecurityClass.get_trusec('F').should == Range.new(0.00, -0.25) }
    specify { SecurityClass.get_trusec('J1').should == Range.new(-0.35, -0.25) }
  end

  describe "ores by space" do
    specify { SecurityClass.ores_by_space('caldari')
                .should == ["Veldspar", "Scordite", "Pyroxeres",
                            "Plagioclase", "Kernite", "Hedbergite"] }

    specify { SecurityClass.ores_by_space('Gallente')
                .should == ["Veldspar", "Scordite", "Plagioclase",
                            "Jaspet", "Omber", "Hemorphite"] }
  end

  describe "ores by class" do
    specify { SecurityClass.ores_for_class('A').should == ["Veldspar", "Scordite"] }

    specify { SecurityClass.ores_for_class('B1')
                 .should == ["Veldspar", "Scordite", "Pyroxeres", "Kernite"] }

    specify { SecurityClass.ores_for_class('F7')
                 .should == ["Veldspar", "Scordite", "Plagioclase", "Omber",
                             "Hemorphite", "Hedbergite"] }
  end

  describe "classes for ore" do
    specify { SecurityClass.classes_for_ore("Veldspar")
                 .should == ["A", "B", "B*", "B1", "B2", "B3", "C", "C1",
                             "C2", "D", "D1", "D2", "D3", "E", "E1", "F",
                             "F1", "F2", "F3", "F4", "F5", "F6", "F7"] }

    specify { SecurityClass.classes_for_ore("Pyroxeres")
                 .should ==  ["B", "B1", "B2", "B3", "C", "C1", "C2", "F5"] }

    specify { SecurityClass.classes_for_ore("Hedbergite")
                 .should ==  ["C2", "E1", "F", "F1", "F2", "F3", "F4",
                              "F5", "F6", "F7"] }
  end
end
