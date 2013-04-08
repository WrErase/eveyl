class MarketGroup < ActiveRecord::Base
  scope :top_level, where(:parent_group_id => nil)

  has_many :types

  belongs_to :parent, :class_name => 'MarketGroup', :foreign_key => :parent_group_id

  has_many :children, :class_name => 'MarketGroup', :primary_key => :market_group_id,
                                                    :foreign_key => :parent_group_id

  validates_presence_of :name
  validates :market_group_id, :presence => true, :numericality => true

  def self.minerals
    types = self.find_by_name('Minerals').try(:types)
    raise ActiveRecord::RecordNotFound unless types

    types
  end

  def stub?
    false
    # FIXME - Probably a better way
#    children.empty? || children.map(&:types).flatten.blank?
  end

  def group_chain
    chain = []

    group = self
    while group
      chain.unshift group
      group = group.parent
    end

    chain
  end
end
