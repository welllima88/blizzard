class OrderReturnPayment
  include MongoMapper::EmbeddedDocument
  
  key :amount, Money
  key :payment_type, Lowercase
  key :status, String
  key :card_last_four, String
  key :transaction_id, String
  key :authorization_id, String
  
  def formatted_payment_type
    return "#{self.payment_type.gsub('_', ' ').titleize}"
  end 
  
end