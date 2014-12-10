class Vendor
  include MongoMapper::Document
  before_create :set_id
  
  key :name, Lowercase
  key :phone, Phone
  key :email, Lowercase
  key :po_email, Lowercase
  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  key :country, String
  
  key :status, String
  
  key :account_number, String
  key :url, String
  
  key :tax_rate, Money
  
  #Sales Rep
  key :rep_first_name, String
  key :rep_last_name, String
  key :rep_phone, Phone
  key :rep_alt_phone, Phone
  key :rep_fax, Phone
  key :rep_address, String
  key :rep_city, String
  key :rep_state, String
  key :rep_zip, String
  key :rep_country, String
  
  key :rep_email, Lowercase
  key :rep_custom, String
  
  # Assosiation
  key :company_id, ObjectId
  belongs_to :company
  
  many :products
  many :purchaseorders
  
  def set_id
    self._id = "#{self.company_id}C#{Vendor.all(:company_id => self.company_id).count.to_i+1}"
  end
  
  def tax_decimal
    "#{(self.tax_rate * 0.01)}"
  end
  
end