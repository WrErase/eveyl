class SkillInTraining < ActiveRecord::Base
  self.table_name = 'skill_in_training'

  belongs_to :character
  belongs_to :skill_type, class_name: 'Type', primary_key: :type_id, foreign_key: :type_id

  delegate :name, to: :skill_type, prefix: 'skill', allow_nil: true

  validates :character_id, presence: true
  validates :type_id, presence: true
  validates :to_level, presence: true

  validates :start_sp, presence: true
  validates :destination_sp, presence: true

  def self.update_api_ts(result)
    result.trainingEndTime += ' UTC'
    result.trainingStartTime += ' UTC'
  end

  def self.update_from_api(character_id, result)
    return unless result

    char = Character.find(character_id)
    if result.skillInTraining == '0'
      char.skill_in_training.try(:destroy)
    else
      update_api_ts(result)
      the_update = {end_time: result.trainingEndTime,
                    start_time: result.trainingStartTime,
                    start_sp: result.trainingStartSP,
                    destination_sp: result.trainingDestinationSP,
                    to_level: result.trainingToLevel,
                    type_id: result.trainingTypeID,
                    reported_ts: result.currentTQTime,
                    character_id: character_id,
                   }

      if char.skill_in_training.present?
        char.skill_in_training.update_attributes(the_update)
      else
        t = self.create(the_update)
      end
    end
  end

  def primary_attribute
    attr = skill_type.find_attribute_by_name('primaryAttribute')
    return unless attr

    AttributeType.find(attr.value_int).name
  end

  def secondary_attribute
    attr = skill_type.find_attribute_by_name('secondaryAttribute')
    return unless attr

    AttributeType.find(attr.value_int).name
  end

  def sp_rate_min(character)
    primary = character.send(primary_attribute)
    secondary = character.send(secondary_attribute)

    (primary + (secondary/2)) * 60
  end

  # Calc based on training values
  def sp_rate_hr
    total_sp = destination_sp - start_sp
    total_time = end_time - start_time

    total_sp / total_time * 3600
  end

  def training_min
    (Time.now.utc - start_time) / 60
  end

  def training_time_remaining
    end_time - Time.now.utc
  end
end
