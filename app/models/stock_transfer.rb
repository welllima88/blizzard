class StockTransfer
  include MongoMapper::Document
  before_create :change_id
  
  key :created_at, Time
  key :employee_id, ObjectId
  key :employee_name, String
  key :status, String
  key :fulfill_by, String
  key :fulfill_by_id, ObjectId
  key :item_count, Integer
  key :source_id, ObjectId
  key :source_name, String
  key :destination_id, ObjectId
  key :destination_name, String
  
  key :company_id, ObjectId
  
  many :stock_transfer_products
  
  def change_id
    self._id = "#{Time.now.in_time_zone('UTC').strftime("%y%j%H%M%S")}"
  end
  
  def send_stock_transfer
    item_count = 0
    # make sure stock is still available
    for p in self.stock_transfer_products
      p.qty = self.set_qty_available(p.product_id, self.source_id, p.qty)
      item_count += p.qty.to_i
    end
    self.save
    for p in self.stock_transfer_products
      product = Product.find(p.product_id)
      store_product = product.product_inventorys.select{|sp| sp.store_id.to_s == self.source_id.to_s}.first
      store_product.qty -= p.qty.to_i
      product.in_transfer += p.qty.to_i
      product.save
    end
    'success'
  end
  
  def set_qty_available(product_id, source_id, qty_requested)
    product = Product.find(product_id)
    store_product = product.product_inventorys.select{|sp| sp.store_id.to_s == source_id.to_s}.first
    if qty_requested.to_i > store_product.qty.to_i
      qty_requested = store_product.qty.to_i
    end
    return qty_requested
  end
  
  def receive_stock_transfer
    for p in self.stock_transfer_products
      product = Product.find(p.product_id)
      store_product = product.product_inventorys.select{|sp| sp.store_id.to_s == self.destination_id.to_s}.first
      store_product.qty += p.qty.to_i
      product.in_transfer -= p.qty.to_i
      product.save
    end
    'success'
  end
  
  def cancel_stock_transfer
    if status == 'sent'
      for p in self.stock_transfer_products
        product = Product.find(p.product_id)
        store_product = product.product_inventorys.select{|sp| sp.store_id.to_s == self.source_id.to_s}.first
        store_product.qty += p.qty.to_i
        product.save
      end
    end
    self.destroy
  end
  
  #
  private # Private Area
  #
  
end