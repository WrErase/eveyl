class Account < ActiveRecord::Base
  has_one :api_key, :primary_key => :key_id, :foreign_key => :key_id

  has_many :characters, :primary_key => :key_id, :foreign_key => :key_id

  def self.update_from_api(key_id, result)
    return unless result

    account = self.find_or_initialize_by_key_id(key_id)
    account.update_attributes({paid_until: result.paidUntil,
                               create_date: result.createDate,
                               logon_count: result.logonCount,
                               logon_minutes: result.logonMinutes,
                               cached_until: result.cached_until,
                              }, without_protection: true)
  end

  def shown_characters
    characters.shown
  end

end
