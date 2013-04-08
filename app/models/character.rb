class Character < ActiveRecord::Base
  scope :shown, where(hidden: false)

  belongs_to :api_key, primary_key: :key_id, foreign_key: :key_id

  belongs_to :corporation
  belongs_to :alliance

  has_many :character_assets
  has_many :skills, class_name: 'CharacterSkill'

  has_one :skill_in_training, class_name: 'SkillInTraining'

  delegate :name, to: :corporation, prefix: true, allow_nil: true
  delegate :name, to: :alliance, prefix: true, allow_nil: true

  validates :name, presence: true

  def self.extract_attributes(result)
    {intelligence: result.attributes.intelligence.to_i,
     memory: result.attributes.memory.to_i,
     charisma: result.attributes.charisma.to_i,
     perception: result.attributes.perception.to_i,
     willpower: result.attributes.willpower.to_i,
    }
  end

  def self.update_from_api(key, result)
    return unless result

    c = self.find_or_create_by_character_id(result.characterID.to_i)
    the_update = {name: result.name,
                  dob: result.DoB,
                  gender: result.gender,
                  race: result.race,
                  bloodline: result.bloodLine,
                  ancestry: result.ancestry,
                  clone_name: result.cloneName,
                  clone_sp: result.cloneSkillPoints,
                  balance: result.balance,
                  corporation_id: result.corporationID.to_i,
                  cached_until: result.cached_until,
                  api_key: key,
                 }

    the_update.merge! extract_attributes(result)

    if result.respond_to?(:allianceID)
      the_update[:alliance_id] = result.allianceID
    end

    c.update_attributes(the_update, without_protection: true)
  end

  def build_assets(result)
    return unless result

    CharacterAsset.where(character_id: self.id).destroy_all

    result.assets.each do |asset|
      CharacterAsset.create_from_api(self.id, asset)
    end
  end

  def total_sp
    skills.sum(&:skill_points)
  end

  def get_skill(name)
    skills.find_by_name(name)
  end

  def get_level_for_skill(name)
    get_skill(name).try(:level)
  end
end
