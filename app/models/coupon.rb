class Coupon
  include MongoMapper::Document
  safe
  include ActionView::Helpers::NumberHelper
  before_save :check_status
  
  # General
  key :name, String
  key :code, String
  key :status, Integer, :default => 0 # 0 = inactive, 1 = active
  
  # Validify
  key :start_date, Time
  key :end_date, Time
  key :multiple_coupons, Integer # 0 = no, 1 = yes
  key :minimum_order_price, Money, :default => 0
  key :max_uses, Integer #0 = unlimited
  
  # Discount
  key :discount_value, Money
  key :discount_type, Integer # 0 = %, 1 = $
  
  # Valid Items
  key :departments, Array # All items belonging to this department are included
  key :products, Array # All items in this array are included
  key :excluded_products, Array # All items in this array are excluded
  key :required_items, Array # If items are in this array, discount wil only be applied if item is in the order
  key :required_items_type, Integer, :default => 0 # 0 = all requred items must be in order for discount, 1 = only 1 items in the required items must be in order
  
  # Metrics
  key :uses, Integer, :default => 0
  key :revenue, Money, :default => 0
  key :net_profit, Money, :default => 0
  key :average_revenue, Money, :default => 0
  key :average_net_profit, Money, :default => 0
  
  # Associations
  key :company_id, ObjectId
  belongs_to :company
  
  # Actions
  
  def self.update_metrics(coupon_id, order_id)
    coupon = Coupon.find(coupon_id)
    order = Order.find(order_id)
    coupon.uses = coupon.uses+1
    coupon.revenue = coupon.revenue+order.subtotal
    coupon.net_profit = coupon.net_profit+order.net_profit
    coupon.average_revenue = coupon.revenue/coupon.uses
    coupon.save
  end
  
  # Before Save
  
  def check_status 
    if self.max_uses == 0
      max_uses = 999999999999999999999
    else
      max_uses = self.max_uses
    end
    if self.start_date <= Date.today.to_time && self.end_date >= Date.today.to_time && self.uses <= max_uses
      #self.status = 1
    else
      #self.status = 0
    end
  end
  
end