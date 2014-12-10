class OrderLineItem
  include MongoMapper::EmbeddedDocument
  
  key :name, String
  key :product_id, ObjectId
  key :price, Money
  key :origional_price, Money
  key :qty, Integer
  key :subtotal, Money
  key :tax, Money
  key :total, Money
  key :cost, Money
  key :origional_total, Money
  key :sku, String, :default => ''
  key :net_profit, Money
  key :nontax, Integer, :default => 0
  
  def update_totals(tax_rate)
    self.subtotal = self.price * self.qty
    if self.nontax == 0
      self.tax = self.subtotal * tax_rate
    else
      self.tax = 0
    end
    self.total = self.subtotal+self.tax
    if self.cost >= 0.01
      self.net_profit = (self.price - self.cost)*self.qty
    else
      self.net_profit = self.subtotal
    end
  end
  
end