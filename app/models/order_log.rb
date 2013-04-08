class OrderLog < ActiveRecord::Base
  belongs_to :order

  validates_presence_of :order_id, :price, :vol_remain, :reported_ts

  validates :order_id, :uniqueness => {:scope => :reported_ts}

  def self.log_order(order)
    old = self.where(order_id: order.id, reported_ts: order.reported_ts).first
    return false if old

    log = {:order_id => order.id,
           :price => order.price,
           :vol_remain => order.vol_remain,
           :gen_name => order.gen_name,
           :gen_version => order.gen_version,
           :reported_ts => order.reported_ts,
          }

    self.create(log, :without_protection => true)
  end
end
