class Order
  include MongoMapper::Document
  # Orders must be safely saved into MongoDb
  safe
  
  before_save :update_totals
  after_create :customer_points
  
  # General/Misc
  key :status, Integer # 1 = complete
  key :offline_id, String, :default => nil
  key :created_at, Time
  key :completed_at, Time
  
  # Order Totals
  key :item_count, Integer
  key :subtotal, Money
  key :tax_rate, Float
  key :tax, Money
  key :discount, Money
  key :total, Money
  key :net_profit, Money
  
  # Business Associations
  key :company_id, ObjectId
  belongs_to :company
  key :store_id, ObjectId
  key :store_name, String, :default => ''
  key :register_id, ObjectId
  key :register_name, String
  
  # Customer
  key :customer_id, String
  key :customer_name, String
  belongs_to :customer
  
  # Emailed Receipts
  key :email_receipt, Boolean
  
  # Employee
  key :employee_id, ObjectId
  key :employee_name, String
  
  # Line Items
  many :order_line_items
  
  # Payments
  many :order_payments
  
  # Associations
  many :order_returns
  key :coupon_id, ObjectId
  
  
  # After Create
  
  def customer_points
    # Add register log entries
    register = Register.find(self.register_id)
    current_till = register.till.to_f
    for p in self.order_payments
      if p.payment_type == 'cash' || p.payment_type == 'change'
        current_till += p.amount.to_f
      end
      RegisterLog.register_transaction(p.id, self.register_id, p.amount, p.payment_type, self.employee_id, self.employee_name, self.id.to_s, current_till, 0, self.created_at)
    end
    # Update the registers till
    register.updateTill(current_till)
    # Add points to customer
    if !self.customer_id.blank?
      Customer.add_points(self.customer_id, self.subtotal.to_f, self.total.to_f, self.net_profit.to_f)
      for p in self.order_payments
        if p.payment_type == 'gift_card'
          GiftCard.addCustomerToCard(self.customer_id, p.transaction_id)
        end
      end
    end
    # Update Coupons
    if !self.coupon_id.blank?
      Coupon.update_metrics(self.coupon_id, self.id)
    end
    # Update Stock
    for i in self.order_line_items
      Product.remove_inventory(i.product_id, i.qty, self.store_id)
    end
    # Email Receipt
    if self.email_receipt == true
      CompanyMailer.email_receipt(self.company, self.customer, self).deliver
    end
  end
  
  
  #
  # Order Actions
  #
  
  def add_line_item(product, line_item_info)
    line_item = OrderLineItem.select{|i| i.product_id == product.id}.first
    if line_item == nil
      line_item = OrderLineItem.new
    end
    line_item.product_id = product.id
    line_item.price = product.price
    line_item.cost = product.cost
    line_item.qty = line_item_info.qty.to_i
    line_item.total = line_item.qty*line_item.price
    self.order_line_items << line_item
    self.save
  end
  
  def remove_line_item(product, line_item_info)
    line_item = OrderLineItem.select{|i| i.product_id == product.id}.first
    if line_item != nil
      line_item.qty = line_item_info.qty
    end
    if line_item.qty == 0
      self.order_line_items.delete_if{|i| i.qty == 0}
    end
    self.save
  end
  
  #
  # Before Filters
  #
  
  def update_totals
    for i in self.order_line_items
      i.update_totals(self.tax_rate.to_f)
    end
    self.item_count = self.order_line_items.to_a.sum(&:qty)
    #self.subtotal = self.order_line_items.to_a.sum(&:subtotal)
    #self.tax = self.order_line_items.to_a.sum(&:tax)
    #self.total = self.tax+self.subtotal
    self.net_profit = self.order_line_items.to_a.sum(&:net_profit)
  end
  
end