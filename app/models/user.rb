class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  scope :admin, where(admin: true)

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts
  has_many :api_keys
  has_many :characters, :through => :accounts

  has_one :user_profile, :dependent => :destroy

  after_create :create_user_profile

  def has_keys?
    !api_keys.empty?
  end

  def character_ids
    self.characters.pluck(:character_id)
  end

  def has_character?(id)
    character_ids.include?(id)
  end
end
