class PoItem
  include MongoMapper::EmbeddedDocument
  before_save :check_complete
  
  key :name, String
  key :upc, String
  key :vendor_sku, String
  key :qty, Integer
  key :cost, Money
  key :total, Money
  key :product_id, ObjectId
  key :manufacturer_id, ObjectId
  key :manufacturer_name, String
  key :manufacturer_sku, String
  key :received, Integer, :default => 0
  key :received_employee_id, ObjectId
  key :received_employee_name, String
  key :all_received, String
  
  belongs_to :purchaseorder
  
  def remaining
    self.qty-self.recieved
  end
  
  def total
    self.cost*self.qty
  end
  
  def check_complete
    self.total = self.cost*self.qty
    if self.qty == self.received
      self.all_received = 'yes'
    else
      self.all_received = 'no'
    end
  end
end
