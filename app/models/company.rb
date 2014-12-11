require 'digest/sha2'
class Company
  include MongoMapper::Document
  #include GeoKit::Geocoders

  
  Company.ensure_index(:api_token)
  
  # Set Timestamps
  timestamps!
  
  # Change the ID when saving into MongoDB
  before_create :change_id
  
  def change_id
    self.id = (Company.count().to_i+1).to_s
    generateAPIToken
  end
  
  # Update location on save
  before_save :update_location
  
  def update_location
    #require 'geokit'
    #coordinates = MultiGeocoder.geocode("#{self.company_address}, #{self.company_city}, #{self.company_state} #{self.company_zip}, #{self.company_country}")
    #self.longitude = coordinates.lat
    #self.latitude = coordinates.lng
  end
  
  # General
  key :company_name, String
  key :company_phone, Phone
  key :company_email, Lowercase
  key :company_fax, Phone
  key :company_address, String
  key :company_address2, String
  key :company_city, Lowercase
  key :company_state, Lowercase
  key :company_zip, String
  key :company_country, Lowercase
  key :last_product_update, Integer
  
  # Location Settings
  key :company_timezone, String
  key :longitude, String
  key :latitude, String

  # Points system
  key :enable_points, Integer, :default => 1 # 1 = enabled, 0 = disabled
  key :points, String # each dollar spent = 1 point
  key :point_value, Money # value of 1 point in dollars
  key :point_payout, Integer # how many points accumulated until a paypout gift card
  key :point_half_life, Integer # how many days payout gift card is valid 
  
  # Employee Commission
  key :enable_commission, Integer, :default => 0
  key :default_commission, Money, :default => 0
  
  # Emailed Receipts
  key :email_receipts, Integer, :default => 0 # 0 = inactive, 1 = active
  key :from_email, String
  key :smtp_user, String
  key :smtp_pass, String
  key :smtp_host, String
  key :smtp_port, Integer
  
  def email_receipts_human
    if self.email_receipts == 0
      return 'OFF'
    else
      return 'ON'
    end
  end
  
  # Associations
  many :stores
  many :customers
  many :employees
  many :departments
  many :vendors
  many :manufacturers
  
  # API Token
  key :api_token, String
  
  def generateAPIToken
    self.api_token = "#{SecureRandom.base64(20).to_s.gsub(/[^0-9A-Za-z]/, '')}#{self.id}"
  end
  
end
