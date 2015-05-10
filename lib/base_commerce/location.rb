require_relative 'address.rb'
require_relative 'pos.rb'
require_relative 'internet.rb'
require_relative 'moto.rb'
require_relative 'ach_details'
require_relative 'bank_card_details.rb'
require_relative 'terminal.rb'
require_relative 'principal_contact.rb'
require_relative 'ach_details.rb'
require 'date'
require 'json'

=begin
  This class represents a Location in the Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class Location
  
  
def self.xs_industry_agriculture
	'Agriculture'
end
 
def self.xs_industry_apparel
	'Apparel'
end
 
def self.xs_industry_banking
	'Banking'
end
 
def self.xs_industry_biotechnology
	'Biotechnology'
end
 
def self.xs_industry_chemicals
	'Chemicals'
end
 
def self.xs_industry_communications
	'Communications'
end
 
def self.xs_industry_construction
	'Construction'
end
 
def self.xs_industry_consulting
	'Consulting'
end
 
def self.xs_industry_education
	'Education'
end
 
def self.xs_industry_electronics
	'Electronics'
end
 
def self.xs_industry_energy
	'Energy'
end
 
def self.xs_industry_engineering
	'Engineering'
end
 
def self.xs_industry_entertainment
	'Entertainment'
end
 
def self.xs_industry_environment
	'Environment'
end
 
def self.xs_industry_finance
	'Finance'
end
 
def self.xs_industry_food_and_beverage
	'Food & Beverage'
end
 
def self.xs_industry_government
	'Government'
end
 
def self.xs_industry_healthcare
	'Healthcare'
end
 
def self.xs_industry_hospitality
	'Hospitality'
end
 
def self.xs_industry_insurance
	'Insurance'
end
 
def self.xs_industry_machinery
	'Machinery'
end
 
def self.xs_industry_manufacturing
	'Manufacturing'
end
 
def self.xs_industry_media
	'Media'
end
 
def self.xs_industry_recreation
	'Recreation'
end
 
def self.xs_industry_retail
	'Retail'
end
 
def self.xs_industry_shipping
	'Shipping'
end
 
def self.xs_industry_technology
	'Technology'
end
 
def self.xs_industry_telecommunications
	'Telecommunications'
end
 
def self.xs_industry_transportation
	'Transportation'
end
 
def self.xs_industry_utilities
	'Utilities'
end
 
def self.xs_industry_other
	'Other'
end
 
def self.xs_ownership_public
	'Public'
end
 
def self.xs_ownership_private
	'Private'
end
 
def self.xs_ownership_subsidiary
	'Subsidiary'
end
 
def self.xs_ownership_other
	'Other'
end

def self.xs_lead_source_3rd_party
	'3rd Party'
end
 
def self.xs_lead_source_outbound_marketing
	'Outbound Marketing'
end
 
def self.xs_lead_source_merchant_referral
	'Merchant Referral'
end
 
def self.xs_lead_source_reseller_partners
	'Reseller Partners'
end
 
def self.xs_lead_source_online
	'Online'
end
 
def self.xs_lead_source_other
	'Other'
end
 
def self.xs_lead_source_referral_partner
	'Referral Partner'
end
 
def self.xs_description_accounting
	'Accounting'
end
 
def self.xs_description_apparel
	'Apparel'
end
 
def self.xs_description_art_photo_film
	'Art / Photo / Film'
end
 
def self.xs_description_barber_hair_salon
	'Barber / Hair Salon'
end
 
def self.xs_description_catering
	'Catering'
end
 
def self.xs_description_cleaning_services
	'Cleaning Services'
end
 
def self.xs_description_computer_services
	'Computer Services'
end
 
def self.xs_description_consulting
	'Consulting'
end
 
def self.xs_description_construction
	'Construction'
end
 
def self.xs_description_dentistry
	'Dentistry'
end
 
def self.xs_description_food_grocery
	'Food / Grocery'
end
 
def self.xs_description_health_care
	'Health Care'
end
 
def self.xs_description_landscaping
	'Landscaping'
end
 
def self.xs_description_legal_services
	'Legal Services'
end
 
def self.xs_description_membership_organization
	'Membership Organization'
end
 
def self.xs_description_other
	'OTHER'
end
 
def self.xs_description_personal_services
	'Personal Services'
end
 
def self.xs_description_real_estate
	'Real Estate'
end
 
def self.xs_description_repair_servics
	'Repair Services'
end
 
def self.xs_description_restaurant_bar
	'Restaurant / Bar'
end
 
def self.xs_description_retail
	'Retail'
end
 
def self.xs_description_shipping
	'Shipping'
end
 
def self.xs_description_taxi_limo
	'Taxi / Limo'
end
 
def self.xs_description_trade_contractor
	'Trade Contractor'
end
 
def self.xs_description_veterinary
	'Veterinary'
end
 
def self.xs_description_web_design_development
	'Web Design / Development'
end

def self.xs_new_visa_utility_acceptor_yes
	'Yes'
end
 
def self.xs_new_visa_utility_acceptor_no
	'No'
end
 
def self.xs_new_visa_utility_acceptor_not_applicable
	'Not Applicable'
end

def self.xs_utility_ownership_public
	'Public'
end
 
def self.xs_utility_ownership_private
	'Private'
end

  def initialize( )
    @lead_sources = Array::new
    @terminals = Array::new
    @principal_contacts = Array::new
  end
  
  attr_accessor :annual_revenue, :contact_name, :contact_email, :e_fax, :contact_mobile, :contact_title,
  :contact_same_as_owner, :fax, :industry, :ownership, :description, :years_in_business, :organization_mission,
  :entity_start_date, :entity_state, :alternative_fax, :year_incorporated, :description_of_products_and_services,
  :length_of_current_ownership, :quantity_of_locations, :waive_pg, :partner_biller_id, :partner_reseller_id,
  :partner_sub_account_id, :program_pricing, :program_details, :lead_sources, :sales_agent_name, :parent_id,
  :additional_description, :new_visa_utility_acceptor, :tax_exempt, :total_customers, :utility_ownership,
  :tax_exempt, :total_customers, :utility_ownership, :dba_address, :terminals, :principal_contacts,
  :bank_card_details, :ach_details, :moto, :internet, :pos,:messages


=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :location
  end
  
=begin
  Updates the key with the objects json prefix

  @return the updated json key
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def get_qualified_key(key)
      "#{json_prefix}_#{key}".to_sym
  end
  
=begin
  Returns a json object representation of the Location
  @params Options any options for modifying the output JSON
  @returns The json representation of this location
  @author Steven Wright <steven.wright@basecommerce.com>
=end

def to_json(options = nil)
      hash = {}
      
      self.instance_variables.each do |var|
        var_text = var[1..-1]
        if ( var_text == "entity_start_date" )
          
          o_date = self.instance_variable_get var
          hash[get_qualified_key(var_text)] = o_date.strftime( "%m/%d/%Y %H:%M:%S" )
          
        elsif ( var_text == "dba_address" )
          
          o_dba_addr = self.instance_variable_get( var )
          
          hash[get_qualified_key(var_text)] = o_dba_addr.to_json
          
        elsif ( var_text == "bank_card_details")
          o_bcd = self.instance_variable_get( "@bank_card_details" )
          hash["location_bc_details"] = o_bcd
          
        elsif ( var_text == "ach_details" )
          
          o_achd = self.instance_variable_get( "@ach_details" )
          hash[get_qualified_key( var_text ) ] = o_achd
          
        else
          
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
          
        end
        
      end
      
      return hash.to_json
  end

=begin
  Builds and Returns a Location object based off of the JSON input.

  @param vo_json   JSON representation of a Location object
  @return  the Location Object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(string)
    
      s_prefix = "location"
      
      JSON.load(string).each do |var, val|
        
      
        if ( var.include? s_prefix )
            
            var = "@" + var[s_prefix.size+1..-1]
  
              if ( var == "@dba_address")
                    
                o_dba = Address.new
                self.instance_variable_set( "@dba_address", o_dba.build_from_json( val.to_json ) )
                  
              elsif ( var == "@ach_details" )
                
                o_ach = ACHDetails.new
                self.instance_variable_set( "@ach_details" , o_ach.build_from_json( val.to_json ) )
                   
              elsif ( var == "@moto" )
                
                o_moto = Moto.new
                self.instance_variable_set( "@moto" , o_moto.build_from_json( val.to_json ) )
                  
              elsif ( var == "@internet" )
                
                o_internet = Internet.new
                self.instance_variable_set( "@internet" , o_internet.build_from_json( val.to_json ) )
                
              elsif ( var == "@pos" )
                
                o_pos = POS.new
                self.instance_variable_set( "@pos" , o_pos.build_form_json( val.to_json ) )
                
              elsif ( var == "@bank_card_details")
                  
                o_bcd = BankCardDetails.new
                self.instance_variable_set( "@bank_card_details", o_bcd.build_from_json( val.to_json ) )
                
              elsif ( var == "@ach_details")
                  
                o_bcd = BankCardDetails.new
                self.instance_variable_set( "@ach_details", o_bcd.build_from_json( val.to_json ) )
                                
              elsif ( var == "@entity_start_date" )
              
                o_date = Date.strptime(val, "%m/%d/%Y %H:%M:%S" )
                self.instance_variable_set("@entity_start_date", o_date)
                
              elsif ( var == "@lead_sources" )
                  
                  val.each{|elem|self.instance_variable_get( "@lead_sources" ).push( elem ) }
                
              elsif ( var == "@terminals" )
                
                  val.each{ |elem| self.instance_variable_get("@terminals").push( elem  ) }
                  
              elsif ( var == "@principal_contacts" )
                
                  val.each{ |elem| self.instance_variable_get( "@principal_contacts").push( elem ) }

              else
                
                self.instance_variable_set( var, val )
                
              end
        
        elsif ( var == "messages" )
          
          self.instance_variable_set( "@messages", val )
          
        end
        
      end
      
end

end