class InventoryLocation
  include MongoMapper::Document
  
  key :company_id, ObjectId
  key :store_id, ObjectId
  key :name, String
  key :isle, String
  key :row, String
  key :shelf, String
  key :position, String
  key :rack, String
  
  belongs_to :store
  
end