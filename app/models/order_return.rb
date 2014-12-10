class OrderReturn
  include MongoMapper::Document
  # Be safe!
  safe
  before_create :logTransactions
  after_create :afterCreate
  
  # General/Misc
  key :status, String
  key :offline_id, String, :default => nil
  key :created_at, Time
  key :completed_at, Time
  key :customer_name, String
  
  # Order Totals
  key :item_count, Integer
  key :subtotal, Money
  key :tax_rate, Float
  key :tax_refunded, Money
  key :total_refunded, Money
  
  # Business Associations
  key :company_id, ObjectId
  belongs_to :company
  key :store_id, ObjectId
  key :store_name, String, :default => ''
  key :register_id, ObjectId
  key :register_name, String
  
  # Embedded Fields
  
  many :order_return_payments
  many :order_return_line_items
  
  # Associations
  key :order_id, ObjectId
  belongs_to :order
  belongs_to :store
  key :customer_id, ObjectId
  key :employee_id, ObjectId
  key :employee_name, String
  
  def logTransactions
    register = Register.find(self.register_id)
    current_till = register.till.to_f
    for p in self.order_return_payments
      if p.payment_type == 'cash' || p.payment_type == 'change'
        current_till -= p.amount.to_f
      end
      RegisterLog.register_transaction(p.id, self.register_id, p.amount, p.payment_type, self.employee_id, self.employee_name, self.id.to_s, current_till, 1, self.created_at)
    end
    register.updateTill(current_till)
  end
  
  def afterCreate
    # Add Stock Back To Store
    for i in self.order_return_line_items
      Product.add_inventory(i.product_id, 1, self.store_id)
    end
  end
  
end