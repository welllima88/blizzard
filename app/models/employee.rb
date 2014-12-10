require 'digest/sha2'
class Employee
  include MongoMapper::Document
  safe
  
  # Password Area
  attr_accessor :new_password, :new_password_confirmation
  validates_confirmation_of :new_password, :if => :password_changed?
  before_save :hash_new_password, :if => :password_changed?
      
  def password_changed?
     !@new_password.blank?
  end
  
  # General
  key :first_name, String
  key :last_name, String
  key :email, Lowercase
  key :phone, Phone
  key :address, String
  key :city, Lowercase
  key :state, Lowercase
  key :zip, Lowercase
  key :country, Lowercase
  key :ssn, Integer
  key :dob, Time, :default => Time.now
  
  # Status
  key :start_date, Time, :default => Time.now
  key :end_date, Time
  key :status, Boolean, :default => true
  
  # Compensation Information
  key :compensation, Money, :default => 0
  key :compensation_type, String, :default => 'hourly'
  
  # Login
  key :username, Lowercase
  key :salt, String
  key :hashed_password, String
  key :reset_key, String
  key :new_password2, String
  
  # Authorizations
  key :super_admin, Boolean, :default => false
  key :sales, Boolean, :default => false
  key :inventory, Boolean, :default => false
  key :employees, Boolean, :default => false
  key :giftcards, Boolean, :default => false
  key :customers, Boolean, :default => false
  key :stores, Boolean, :default => false
  key :marketing, Boolean, :default => false
  key :returns, Boolean, :default => false
  
  # Associations
  key :company_id, ObjectId
  
  #
  # Quicks
  #
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  # Password area
  
  def self.authenticate(company_id, username, password)
    if user = Employee.where(:company_id => company_id, :username => username.downcase).first
      if user.hashed_password == Digest::SHA2.hexdigest(user.salt + password)
        return user
      end
    end
    return nil
  end
  
  def resetPassword
    self.reset_key = ("#{SecureRandom.base64(6)}#{Time.now.to_i}").to_s.gsub(/[^0-9A-Za-z]/, '')
    CompanyMailer.reset_password(self).deliver
    self.save
  end

  # Admin Access
  
  def admin_access
    access = []
    if self.super_admin == true
      access << 'all'
    else
      if self.sales == true
        access << 'sales'
      end
      if self.inventory == true
        access << 'inventory'
      end
      if self.employees == true
        access << 'employees'
      end
      if self.giftcards == true
        access << 'giftcards'
      end
      if self.customers == true
        access << 'customers'
      end
      if self.stores == true
        access << 'stores'
      end
      if self.marketing == true
        access << 'marketing'
      end
    end
    return access
  end
  
  # Private
  private
  
  def hash_new_password
    self.salt = SecureRandom.base64(8)
    self.hashed_password = Digest::SHA2.hexdigest(self.salt + @new_password)
  end
  
end