class OrderReturnLineItem
  include MongoMapper::EmbeddedDocument
  
  key :name, String
  key :price, Money
  key :product_id, ObjectId
  
end