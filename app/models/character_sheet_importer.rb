class CharacterSheetImporter
  attr_reader :character_id, :key, :sheet

  def initialize(options = {})
    @key   = options[:key]
    @sheet = options[:sheet]

    @character_id = @sheet.characterID.to_i
  end

  def load_skills
    sheet.skills.each do |skill|
      CharacterSkill.update_from_api(character_id, skill)
    end
  end

  def load_character
    Character.update_from_api(key, sheet)
  end

  def load_enhancers
  end

  def load_sheet
    load_character
    load_skills
    load_enhancers
  end
end
