class CommissionItem
  include MongoMapper::EmbeddedDocument
  
  key :product_id, ObjectId
  key :product_name, String
  key :product_price, String
  key :product_cost, Money
  key :product_commission, Money
  key :product_qty, Integer
  key :total, Money


end
