class PoPayment
  include MongoMapper::EmbeddedDocument
  
  key :payment_type, String
  key :payment_name, String
  key :amount, Money
  key :created_at, Time
  key :transaction_id, String
  
  embedded_in :purchaseorder
end
