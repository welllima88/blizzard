class MerchantApplication
  include MongoMapper::Document
  
  # Association
  key :company_id, ObjectId
  
  # Internal Use
  key :status, Integer # 0 = new, 1 = processing, 2 = waiting for signature, 3 = submitted, 4 = approved, 5 = declined, 6 = on hold
  key :plan_name, String 
  
  # Section 1 (Merchant Information)
  key :dba_name, String
  key :legal_name, String
  key :legal_address, String
  key :legal_city, String
  key :legal_state, String
  key :legal_zip, String
  key :legal_country, String
  key :dba_address, String
  key :dba_city, String
  key :dba_state, String
  key :dba_zip, String
  key :dba_country, String
  
  key :contact_name, String
  key :contact_phone, Phone
  key :location_phone, Phone
  key :location_fax, Phone
  key :customer_service_phone, Phone
  key :website, String
  key :invoice_address, Integer # 0 = legal Address, 1 = DBA
  key :seasonal, Integer # 0 = no, 1 = yes
  key :merchant_email, String
  key :receipt_address, Integer # 0 = legal Address, 1 = DBA
  
  # Section 2 IRS Disclosure
  key :irs_name, String
  key :tax_id, String
  key :tax_id_type, Integer # 0 = SSN, 1 = EIN
  key :business_type, Integer # 0 = sole prop, 1 = C Corp, 2 = S Corp, 3 = LLC, 4 = Partnership, 5 = Trust/estate
  
  # Section 3 Owner Officers
  key :owner1_name, String
  key :owner1_equity, Integer
  key :owner1_ssn, String
  key :owner1_title, String
  key :owner1_phone, Phone
  key :owner1_address, String
  key :owner1_city, String
  key :owner1_state, String
  key :owner1_zip, String
  key :owner1_dob, String
  key :owner1_license_number, String
  key :owner1_license_state, String
  key :owner1_bankruptcy, Integer # 0 = no, 1 = yes
  key :owner1_bankruptcy_reason, String
  
  key :owner2_name, String
  key :owner2_equity, Integer
  key :owner2_ssn, String
  key :owner2_title, String
  key :owner2_phone, Phone
  key :owner2_address, String
  key :owner2_city, String
  key :owner2_state, String
  key :owner2_zip, String
  key :owner2_dob, String
  key :owner2_license_number, String
  key :owner2_license_state, String
  key :owner2_bankruptcy, Integer # 0 = no, 1 = yes
  key :owner2_bankruptcy_reason, String
  
  # Section 4 Merchant Profile
  key :product_delivery_time, String
  key :product_fulfillment, Integer # 0 = merchant, 1 = vendor, 2 = other
  key :vendor_name, String
  key :vendor_address, String
  key :vendor_city, String
  key :vendor_state, String
  key :vendor_zip, String
  key :vendor_phone, Phone
  
  key :deposit_required, Integer # 0 = no, 1 = yes
  key :deposit_percentage, Integer
  
  key :swiped_percentage, Integer
  key :ecommerce_percentage, Integer
  key :mail_percentage, Integer
  key :phone_percentage, Integer
  
  key :gross_yearly_volume, Money
  key :average_card_volume, Money
  key :average_ticket, Money
  key :highest_ticket, Money
  
  # Section 5 Banking Information
  key :bank_name, String
  key :bank_contact, String
  key :bank_phone, String
  key :account_type, Integer #0 = checking, 1 = savings
  key :bank_routing_number, String
  key :bank_account_number, String
  
  # Section 6 Existing Entitlements
  key :accept_amex, String
  key :existing_amex, Integer # 0 = no, 1 = yes
  key :amex_se_number, String
  key :amex_ebt_fns, String
  
  # Section 7 Vendor Trade References
  key :reference1_name, String
  key :reference1_contact, String
  key :reference1_phone, Phone
  key :reference1_address, String
  key :reference1_city, String
  key :reference1_state, String
  key :reference1_zip, String
  key :reference1_account_number, String
  
  key :reference2_name, String
  key :reference2_contact, String
  key :reference2_phone, Phone
  key :reference2_address, String
  key :reference2_city, String
  key :reference2_state, String
  key :reference2_zip, String
  key :reference2_account_number, String
  
  # Section 8 Merchant Site Survey / Business Details
  key :product_service_sold, String
  key :selling_location, Integer # 0 = retail, 1 = restaurant, 2 = hotel, 3 = gas, 4 = tradeshow, 5 = car rental, 6 = e-commerce, 7 = moto
  key :length_of_ownership, String
  key :business_location_type, Integer # 0 = retail, 1 = office, 2 = home, 3 = restaurant, 4 = mixed use, 5 = mobile
  key :business_incorporation_date, String
  key :business_incorporation_state, String
  key :previous_processor, String
  key :reason_for_leaving, String
  key :business_area_zoned, Integer # 0 = commercial, 1 = industrial, 2 = residential
  key :square_footage, Integer
  key :number_of_registers, Integer
  key :number_of_employees, Integer
  key :main_advertising_method, Integer # 0 = Catalog, 1 = broucure, 2 = direct mail, 3 = tv/radio, 4 = internet, 5 = phone
  key :signage_displayed, String
  
  
  #
  # Helpers
  #
  
  def status_human
    values = ['New', 'Processing', 'Waiting for Signature', 'Submitted to EPI', 'Approved', 'Declined', 'On Hold']
    return values[self.status].to_s
  end
  
end