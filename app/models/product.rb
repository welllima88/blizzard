class Product
  include MongoMapper::Document
  safe
  
  # Automatic
  before_save :calculate_stock
  
  # General
  key :name, String
  key :inventory_count, Integer
  key :stock, Integer, :default => 0
  key :reorder_level, Integer, :default => 0
  key :desired_level, Integer, :default => 0
  key :min_store_level, Integer, :default => 0
  key :on_order, Integer, :default => 0
  key :in_transfer, Integer, :default => 0
  key :cost, Money, :default => 0
  key :vendor_name, String
  key :manufacturer_id, ObjectId
  key :manufacturer_name, String
  key :created_at, Time
  key :low_stock, Integer, :default => 0
  key :status, Integer # 0 = De-Active, 1 = Active
  key :nontax, Integer, :default => 0 # 0 = taxable 1 = nontaxable
  
  # Commission
  key :enable_commission, Integer, :default => 1
  key :commission_overide, Integer, :default => 0
  key :commission_overide_amount, Money, :default => 0
  
  # Location
  key :isle, String
  key :shelf, String
  
  # IDS
  key :upc, Lowercase, :default => ''
  key :sku, Lowercase, :default => ''
  key :ean, Lowercase, :default => ''
  key :m_sku, Lowercase, :default => ''
  key :pid, String
  
  # tags
  key :tags, Lowercase
  
  # Pricing
  key :cost, Money
  key :price, Money
  key :sale_price, Money
  key :return_price, Money
  
  # Associations
  key :company_id, ObjectId
  key :department_id, ObjectId
  belongs_to :department
  
  key :manufacturer_id, ObjectId
  belongs_to :manufacturer
  
  key :vendor_id, ObjectId
  belongs_to :vendor
  
  many :product_inventorys
  
  #
  # Actions
  #
  
  # PRODUCT SEARCHING
  
  def self.product_seach(company_id, product_id)
    if product_id == nil || product_id == ''
      return nil
    end
    product = Product.first(:company_id => company_id, :$or => [{:upc => product_id}, {:sku => product_id}, {:ean => product_id}, {:id => product_id}, {:name => product_id}])
    if product == nil
      return nil
    else
      return product
    end
  end
  
  def adaquate_level
    min_reorder = self.reorder_level.to_i - (self.stock.to_i + self.on_order.to_i + self.in_transfer.to_i)
    if self.desired_level >= min_reorder
      return self.desired_level-(self.stock.to_i + self.on_order.to_i + self.in_transfer.to_i)
    else
      return min_reorder
    end
  end
  
  def self.verify_unique(company_id, upc, ean, sku, m_sku, product_id)
    check_upc = Product.first(:company_id => company_id, :$or => [{:upc => upc}, {:sku => upc}, {:ean => upc}, {:id => upc}, {:name => upc}]) unless upc == ''
    check_ean = Product.first(:company_id => company_id, :$or => [{:upc => ean}, {:sku => ean}, {:ean => ean}, {:id => ean}, {:name => ean}]) unless ean == ''
    check_sku = Product.first(:company_id => company_id, :$or => [{:upc => sku}, {:sku => sku}, {:ean => sku}, {:id => sku}, {:name => sku}]) unless sku == ''
    check_m_sku = Product.first(:company_id => company_id, :$or => [{:upc => m_sku}, {:sku => m_sku}, {:ean => m_sku}, {:id => m_sku}, {:name => m_sku}]) unless m_sku == ''
    if check_upc && check_upc.id.to_s != product_id
      return "The Product: #{check_upc.name.capitalize} already uses the UPC code: #{upc}"
    end
    if check_ean && check_ean.id.to_s != product_id
      return "The Product: #{check_ean.name.capitalize} already uses the EAN code: #{ean}"
    end
    if check_sku && check_sku.id.to_s != product_id
      return "The Product: #{check_sku.name.capitalize} already uses the SKU code: #{sku}"
    end
    if check_m_sku && check_m_sku.id.to_s != product_id
      return "The Product: #{check_m_sku.name.capitalize} already uses the Manufacture SKU code: #{m_sku}"
    end
    true
  end
  
  # EDIT STOCK
  
  def calculate_stock    
    self.stock = self.product_inventorys.to_a.sum(&:qty)
    if (self.stock.to_i + self.on_order.to_i + self.in_transfer.to_i).to_i > self.reorder_level.to_i
      self.low_stock = 0
    else
      self.low_stock = 1
    end
    
    if self.name_changed? || self.ean_changed? || self.upc_changed? || self.sku_changed? || self.m_sku_changed?
      self.tags = "#{self.name} #{self.id} #{self.upc} #{self.sku} #{self.m_sku} #{self.ean}"
    end
    
    self.tags = "#{self.name} #{self.id} #{self.upc} #{self.sku} #{self.m_sku} #{self.ean}"
    
  end
  
  def self.remove_inventory(product_id, qty, store_id)
    product = Product.find(product_id)
    item = product.product_inventorys.select{|i| i.store_id.to_s == store_id.to_s}.first
    item.qty -= qty
    product.save
    product.calculate_stock
  end
  
  def self.add_inventory(product_id, qty, store_id)
    product = Product.find(product_id)
    item = product.product_inventorys.select{|i| i.store_id == store_id}.first
    item.qty += qty
    product.save
    product.calculate_stock
  end
  

  # Methods/Actions

  def set_return_price(price)
    if self.return_price.to_f > price.to_f
      self.return_price = price.to_f
      self.save
    end
  end
  
  
end