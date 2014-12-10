class ProductInventoryLocations
  include MongoMapper::EmbeddedDocument
  before_save :check_stock
  
  key :store_id, ObjectId
  key :qty, Integer
  
end