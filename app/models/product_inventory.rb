class ProductInventory
  include MongoMapper::EmbeddedDocument
  before_save :check_stock
  
  key :store_id, ObjectId
  key :qty, Integer
  
  def check_stock
    if self.qty == nil
      self.qty = 0
    end
  end
end