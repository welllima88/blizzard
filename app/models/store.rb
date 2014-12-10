class Store
  include MongoMapper::Document
  safe
  
  # Change id to something short and unique
  before_create :change_id
  after_create :add_store_to_inventory
  
  def change_id
    self.id = "#{self.company_id}E#{Store.where(:company_id => self.company_id).count}"
    self._id = "#{self.company_id}E#{Store.where(:company_id => self.company_id).count}"
  end
  
  # General
  key :name, String
  key :phone, Phone
  key :address, String
  key :address2, String, :default => ''
  key :city, Lowercase
  key :state, String
  key :zip, Lowercase
  key :country, Lowercase
  key :tax_rate, Money
  key :time_zone, String
  key :email, String
  
  # Locale
  key :currency_code, String, :default => '$'
  
  # Payment Gateway
  key :gateway, String
  key :gateway_storename, String
  key :gateway_username, String
  key :gateway_password, String
  key :gateway_status, String
  
  # Associations
  key :company_id, ObjectId
  many :registers
  belongs_to :company
  many :inventory_locations
  
  def full_address
    "#{self.address}<br>#{self.city} #{self.state}, #{self.zip}"
  end
  
  def tax_to_decimal
    (self.tax_rate.to_f/100).to_f
  end
  
  def add_store_to_inventory
    for p in Product.all(:company_id => self.company_id)
      product_inventory = p.product_inventorys.select{|pi| pi.store_id.to_s == self.id.to_s}.first
      if product_inventory == nil
        product_inventory = ProductInventory.new(:store_id => self.id, :qty => 0)
        p.product_inventorys << product_inventory
        p.save
      end
    end
  end
  
end