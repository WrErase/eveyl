# Security Class detail
# http://eveinfo.net/complexes/index~22.htm
class SecurityClass
  ORES_BITMAP = ['Veldspar', 'Scordite', 'Pyroxeres', 'Plagioclase',
                 'Jaspet', 'Gneiss', 'Kernite', 'Omber', 'Dark Ochre',
                 'Crokite', 'Bistot', 'Mercoxit', 'Arkonor', 'Spodumain',
                 'Hemorphite', 'Hedbergite']

  # Security Mappings
  def self.trusec_map
    {'A'  => 0.95..1.00,
     'B'  => 0.75..0.95,
     'B1' => 0.45..0.75,
     'B2' => 0.25..0.45,
     'B3' => 0.00..0.25,
     'C'  => 0.45..0.75,
     'C1' => 0.25..0.45,
     'C2' => 0.00..0.25,
     'D'  => 0.75..0.95,
     'D1' => 0.45..0.75,
     'D2' => 0.25..0.45,
     'D3' => 0.00..0.25,
     'E'  => 0.25..0.45,
     'E1' => 0.00..0.25,
    }
  end

  def self.null_trusec_map
    {''  =>  0.00..-0.25,
     '1' => -0.35..-0.25,
     '2' => -0.45..-0.35,
     '3' => -0.55..-0.45,
     '4' => -0.65..-0.55,
     '5' => -0.75..-0.65,
     '6' => -0.85..-0.75,
     '7' => -1.00..-0.85,
    }
  end

  def self.get_trusec(class_name)
    parts = class_name.split('')
    if ['F', 'G', 'H', 'I', 'J', 'K'].include?(parts.first)
      null_trusec_map[parts[1].to_s]
    else
      trusec_map[class_name]
    end
  end


  # Ore Mappings

  def self.ores_map
    # 'B*' are B in Gallente space which have Plagioclase instead of Pyroxeres
    # Should probably be 'D', but database uses 'B'
    {'A'  => '1100000000000000',
     'B'  => '1110000000000000',
     'B*' => '1101000000000000',
     'B1' => '1110001000000000',
     'B2' => '1110101000000000',
     'B3' => '1110101000000010',
     'C'  => '1111000000000000',
     'C1' => '1111001000000000',
     'C2' => '1111001000000001',
     'D'  => '1101000000000000',
     'D1' => '1101000100000000',
     'D2' => '1101100100000000',
     'D3' => '1101000100000010',
     'E'  => '1101001100000000',
     'E1' => '1101001100000001',
     'F'  => '1100000100000011',
     'F1' => '1100000100000111',
     'F2' => '1100010100000011',
     'F3' => '1100000100100011',
     'F4' => '1100000100001011',
     'F5' => '1110000100000011',
     'F6' => '1100000100010011',
     'F7' => '1101000100000011',
    }

    #TODO - G-K
  end

  def self.ores_faction_groups
    {1 => '1110101000000010',
     2 => '1111001000000001',
     3 => '1101001100000001',
     4 => '1101100100000010',
    }
  end

  def self.space_ore_group_map
    {'Ammatar' => 1,
     'Khanid Kingdom' => 1,
     'Concord' => 1,
     'Caldari' => 2,
     'Minmatar' => 3,
     'Gallente' => 4,
    }
  end

  def self.ores_by_space(name)
    name = name.downcase.capitalize

    key = space_ore_group_map[name]
    values = ores_faction_groups[key].split('')

    retval = []
    values.each_index do |idx|
      retval << ORES_BITMAP[idx] if values[idx] == '1'
    end

    retval
  end

  def self.ores_for_class(class_name)
    retval = []

    values = ores_map[class_name].split('')
    values.each_index do |idx|
      retval << ORES_BITMAP[idx] if values[idx] == '1'
    end

    retval
  end

  def self.classes_for_ore(ore_name)
    name = ore_name.downcase.capitalize

    idx = ORES_BITMAP.find_index(name)

    retval = []
    ores_map.each do |k,v|
      retval << k if v.split('')[idx] == '1'
    end

    retval
  end
end
