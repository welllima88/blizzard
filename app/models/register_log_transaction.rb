class RegisterLogTransaction
  include MongoMapper::EmbeddedDocument
  
  timestamps!
  
  # General
  key :amount, Money
  key :card_last_four, String
  key :payment_type, Lowercase
  key :new_till, Money
  
  # Verification/Additions
  key :transaction_type, Integer, :default => 0 # 0 = order, 1 = return, 2 = add, 3 = subtract, 4 = verify
  
  # Associations
  key :employee_id, ObjectId
  key :employee_name, Lowercase
  key :parent_id, String
  key :payment_id, ObjectId
  
  belongs_to :register_log
  
  def assignTimestamp
    if self.transaction_type == 0
      self.created_at = Order.find(self.parent_id).created_at
    end
    if self.transaction_type == 1
      self.created_at = OrderReturn.find(self.parent_id).created_at
    end
    self.register_log.save
  end
  
  # Helpers
  
  def transaction_type_human
    if self.transaction_type == 0
      return 'Sale'
    end
    if self.transaction_type == 1
      return 'Return'
    end
    if self.transaction_type == 2
      return 'Add'
    end
    if self.transaction_type == 3
      return 'Till Subtract'
    end
    if self.transaction_type == 4
      return 'Till Addition'
    end
      
  end
  
  
end