class GiftCardTransaction
  include MongoMapper::EmbeddedDocument
  
  key :order_id, ObjectId
  key :amount, Money
  key :date, Time
  key :store_name, String
  key :store_id, ObjectId
  
end
