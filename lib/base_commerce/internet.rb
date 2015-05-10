require 'json'

=begin
  This class represents an Internet object the Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class Internet
  

def self.xs_delivery_confirmation_carrier_signature_tracking
	'Carrier Signature Tracking'
end
 
def self.xs_delivery_confirmation_merchant_telephone_confirmation
	'Merchant Telephone Confirmation'
end
 
def self.xs_delivery_confirmation_other
	'Other'
end
 
def self.xs_delivery_confirmation_none
	'None'
end
 
def self.xs_return_policy_full_refund
	'Full Refund'
end
 
def self.xs_return_policy_store_credit
	'Store Credit'
end
 
def self.xs_return_policy_no_refunds
	'No Refunds'
end
 
def self.xs_shipped_goods_fedex
	'FedEx'
end
 
def self.xs_shipped_goods_ups
	'UPS'
end
 
def self.xs_shipped_goods_usps
	'USPS'
end
 
def self.xs_shipped_goods_common_freight
	'Common Freight'
end
 
def self.xs_shipped_goods_electronic_delivery_download
	'Electronic Delivery / Download'
end
 
def self.xs_shipped_goods_not_applicable
	'Not Applicable'
end
 
def self.xs_shipped_goods_other
	'Other'
end
 
def self.xs_policies_available_on_website_privacy_policy
	'Privacy Policy'
end
 
def self.xs_policies_available_on_website_return_and_refund_policy
	'Return and Refund Policy'
end
 
def self.xs_policies_available_on_website_terms_of_condition_of_sale
	'Terms of Condition of Sale'
end
 
def self.xs_ssl_certificate_type_individual
	'Individual'
end
 
def self.xs_ssl_certificate_type_shared
	'Shared'
end
 
def self.xs_inventory_owner_merchant
	'Merchant'
end
 
def self.xs_inventory_owner_vendor
	'Vendor'
end
 
  
  attr_accessor :days_between_order_and_shipping,:delivery_confirmation,:deposit,
    :deposit_required,:delivery_of_goods,:return_policy_time_period,:return_policy,
    :shipped_goods,:fulfillment_vendor_utilized,:percent_of_sales_to_non_us_card_holders,
    :website_ip_address,:applicant_owns_web_domain_and_content,:policies_accessible_on_website,
    :web_host_vendor_name,:ssl_certificate_issuer,:ssl_certificate_number,
    :ssl_certificate_type,:gateway_software_vendor,:gateway_software_version,
    :gateway_software_name,:temp_login_credentials,:inventory_owner,
    :fulfillment_vendor,:fulfillment_vendor_phone_number,:messages

=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    @delivery_confirmation = Array.new
    @return_policy = Array.new
    @shipped_goods = Array.new
    @policies_accessible_on_website = Array.new
    @deposit_required = false
    @delivery_of_godds = false
    @fulfillment_vendor_utilized = false
    @applicant_owns_web_domain_and_content = false
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :internet
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
  Returns a json object representation of the Internet object
  @params Options any options for modifying the output JSON
  @returns The json representation of this Internet object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  
  def to_json(options = nil )
    hash = {}

      self.instance_variables.each do |var|

          var_text = var[1..-1]

          if var.is_a? Hash or var.is_a? Array

            hash[get_qualified_key(var_text)] = var.to_json
          else

            hash[get_qualified_key(var_text)] = self.instance_variable_get var
          end

        end
        
        return hash.to_json
  end

=begin
  Builds and Returns an Internet object base off of the JSON input.
  
  @param vo_json  JSON representation of an Internet object
  @return the Location Object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json( vo_json )
    
    s_prefix = "internet"
    JSON.load( vo_json ).each do |var, val|
      
      if ( var.include? s_prefix )
        
        var = "@" + var[s_prefix.size+1..-1]
        
        if( var == "@delivery_confirmation" )
          
          val.each{ |elem| self.instance_variable_get("@delivery_confirmation").push(elem)}
          
        elsif( var == "@return_policy" )
          
          val.each{ |elem| self.instance_variable_get("@return_policy").push(elem)}
          
        elsif( var == "@shipped_goods")
          
          val.each{ |elem| self.instance_variable_get("@shipped_goods").push(elem)}
          
        elsif( var == "@policies_accessible_on_website")
          
          val.each{ |elem| self.instance_variable_get("@policies_accessible_on_website").push(elem)}
          
        else
          
          self.instance_variable_set( var, val )
          
        end
        
      elsif (var == "messages" )
        
        self.instance_variable_set( "@messages", val )
        
      end
      
    end
    
  end
  
end