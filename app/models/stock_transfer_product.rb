class StockTransferProduct 
  include MongoMapper::EmbeddedDocument
  
  key :product_id, ObjectId
  key :product_name, String
  key :qty, Integer
  
end