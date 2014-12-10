class InventoryLog
  include MongoMapper::Document
  timestamps!
  
  key :product_id, ObjectId
  key :parent_id, ObjectId
  key :parent_type, Integer # 0 = sale, 1 = return, 2 = Purchase Order
  key :company_id, ObjectId
  key :qty, Integer
  key :inventoryLocation, ObjectId
  

  
  
end
