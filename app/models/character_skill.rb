class CharacterSkill < ActiveRecord::Base
  scope :published, where(published: true)

  belongs_to :character
  belongs_to :type

  validates :character_id, presence: true,
                           numericality: { greater_than: 0 }

  validates :type_id, presence: true,
                      numericality: { greater_than: 0 }

  validates :level, presence: true,
                    numericality: { greater_than_or_equal_to: 0 }

  validates :skill_points, presence: true,
                           numericality: { greater_than_or_equal_to: 0 }

  delegate :name, to: :type, prefix: 'skill'

  has_one :group, through: :type

  delegate :name, to: :group, prefix: true

  def self.update_from_api(character_id, skill)
    type_id = skill.typeID.to_i

    the_update = {character_id: character_id.to_i,
                  type_id: skill.typeID.to_i,
                  skill_points: skill.skillpoints.to_i,
                  level: skill.level.to_i,
                  published: skill.published == '1' ? true : false }

    skill = find_or_create_by_character_id_and_type_id(character_id, type_id)
    skill.update_attributes(the_update)

    skill
  end

  def self.find_by_name(name)
    joins(:type).where("types.name" => name).first
  end

  def self.group_by_type(character_id)
    includes(:type, :group).where(character_id: character_id).group_by(&:group_name)
  end
end
