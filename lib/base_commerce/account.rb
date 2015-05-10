require 'json'
require_relative 'address.rb'

=begin
  This class represents an Account object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class Account
  
def self.xs_entity_type_corp
	'Corporation'
end
 
def self.xs_entity_type_gov
	'Government'
end
 
def self.xs_entity_type_llc
	'LLC'
end
 
def self.xs_entity_type_non_profit
	'Non-Profit'
end
 
def self.xs_entity_type_non_profit_501c
	'Non-Profit 501(c)'
end
 
def self.xs_entity_type_partnership
	'Partnership'
end
 
def self.xs_entity_type_private_utility
	'Private Utility'
end
 
def self.xs_entity_type_public_utility
	'Public Utility'
end
 
def self.xs_entity_type_sole_proprietor
	'Sole Proprietor'
end
 


  attr_accessor :account_name,:legal_address,:account_phone_number,:referral_partner_id,
    :customer_service_phone_number,:dba,:dda_account_name,:dda_account_number,
    :dda_bank_name,:dda_routing_number,:entity_type,:association_number,:conga_template_id,
    :ein,:ip_address_of_app_submission,:website,:test_account,:accept_ach,:accept_bc,
    :settlement_account_bank_name,:settlement_account_name,:settlement_account_number,
    :settlement_account_bank_phone,:settlement_account_routing_number,:settlement_same_as_fee_account,
    :fee_account_bank_name,:fee_account_name,:fee_account_number,:fee_account_routing_number,
    :fee_account_bank_phone,:messages
=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    @settlement_same_as_fee_account = true
    @test_account = false
    @accept_ach = false
    @accept_bc = false
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :account
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
  Returns a json object representation of the Account
  @params Options any options for modifying the output JSON
  @returns The json representation of this Account
  @author Steven Wright <steven.wright@basecommerce.com>
=end

def to_json(options = nil)
      hash = {}
      
      self.instance_variables.each do |var|
        
        var_text = var[1..-1]
        
        if( var_text == "legal_address")
          
          o_addr = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_addr.to_json
          
        elsif( var_text == "account_name" )
          
        hash["account_name"] = self.instance_variable_get( var )
        
        elsif( var_text == "account_phone_number")
          
          hash["account_phone_number"] = self.instance_variable_get( var )
          
        elsif( var_text == "ip_address_of_app_submission" )
          
          hash["account_ip_address"] = self.instance_variable_get( var )
          
        elsif var.is_a? Hash or var.is_a? Array
          
          hash[get_qualified_key(var_text)] = var.to_json
        else
          
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
        
      end
      return hash.to_json
end

=begin
  Builds an Account object based off of the JSON input.

  @param vo_json   JSON representation of an Account object
  @return  the Account object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(string)
    
      s_prefix = "account"
      
      o_addr = Address.new
      
      JSON.load(string).each do |var, val|
        
        if ( var.include? s_prefix )
          
            var = "@" + var[s_prefix.size+1..-1]
            
            if( val.is_a? Hash )
              
              if( var == "@legal_address" )
                  
                self.instance_variable_set( "@legal_address" ,o_addr.build_from_json( val.to_json ) )
              
              elsif( var == "@ip_address" )
                
                self.instance_variable_set( "@ip_address_of_app_submission", val )
                
              else
                
                  self.instance_variable_set( var, val )
                  
              end
                        
            end

        elsif ( var == "messages" )
          
          self.instance_variable_set( "@messages", val )
          
        end
        
      end
      
  end
  
end