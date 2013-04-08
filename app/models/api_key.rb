class ApiKey < ActiveRecord::Base
  scope :active, lambda { where("expires is null or expires > ?", Time.now) }
  belongs_to :account, :primary_key => :key_id, :foreign_key => :key_id

  has_many :characters, :primary_key => :key_id, :foreign_key => :key_id

  validates :key_id, presence: true,
                     uniqueness: { :scope => :user_id,
                                   :message => 'has already been used'},
                     numericality: { only_integer: true,
                                     allow_blank: true,
                                     greater_than: 0,
                                     less_than: 10_000_000 }

  validates :vcode, presence: true,
                    format: { with: /\A\w{64}\z/, allow_blank: true}

  validates :user_id, presence: true

  def self.admin_key
    User.admin.first.api_keys.active.first
  end

  def load_key_result(result)
    self.access_mask = result.key.accessMask
    self.key_type = result.key.type
    self.expires = result.key.expires
    self.cached_until = result.cached_until
  end

  def test_key
    begin
      result = EveApi.get_key_info(self)
      load_key_result(result)
      retval = true
    rescue Exception => e
      Rails.logger.info "Invalid key parameters: #{key_id}, #{vcode}"
      retval = false
    end

    retval
  end

  def update_from_api(result)
    return unless result

    self.load_key_result(result)
    self.save
  end
end
