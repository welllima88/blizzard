require_relative 'address.rb'
require 'date'

=begin
  This class represents a Principal Contact in the Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class PrincipalContact

  
def self.xs_contact_type_owner
	'Owner'
end
 
def self.xs_contact_type_officer
	'Officer'
end
 
  attr_accessor :id,:account_id,:last_name,:first_name,:mailing_address,:phone_number,:fax,:mobile_phone_number,:email,:title,:birthdate,:authorized_user,:account_signer,:ownership_percentage,:contact_type,:driver_license,:license_state,:ssn,:is_primary

=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    @authorized_user = false
    @account_signer = false
    @is_primary = false
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :principal_contact
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
  Returns a json object representation of the Principal Contact
  @params Options any options for modifying the output JSON
  @returns The json representation of this Principal Contact
  @author Steven Wright <steven.wright@basecommerce.com>
=end

  def to_json(options = nil)
      hash = {}
      
      self.instance_variables.each do |var|
        var_text = var[1..-1]
        
        if ( var_text == "mailing_address" )
          
          o_addr = self.instance_variable_get var
          hash[get_qualified_key(var_text)] = o_addr.to_json
          
        elsif ( var_text == "birthdate" )
          
          o_date = self.instance_variable_get var
          hash[get_qualified_key(var_text)] = o_date.strftime( "%m/%d/%Y %H:%M:%S" )
          
        else
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
      end
      return hash.to_json
  end 
  
=begin
  Builds an Principal Contact object based off of the JSON input.

  @param vo_json   JSON representation of a Principal Contact object
  @return  the Principal Contact object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(string)
    
      s_prefix = "principal_contact"
      
      JSON.load(string).each do |var, val|
        
        if ( var.include? s_prefix )
          
            var = "@" + var[s_prefix.size+1..-1]
            
            if( val.is_a? Hash )
              
              if( var == "@mailing_address" )
                  
                  o_m_addr = Address.new
                  o_m_addr.build_from_json( val.to_json )
                  
                self.instance_variable_set( "@mailing_address" , o_m_addr )
                
              end
             
              
            elsif ( var == "@birthdate" )

               o_date = Date.strptime(val, "%m/%d/%Y %H:%M:%S" )
              self.instance_variable_set("@birthdate", o_date)
              
            elsif( var == "@type" )
                self.instance_variable_set("contact_type", var)
                
            else            
              
              self.instance_variable_set( var, val )
              
            end

        elsif ( var == "messages" )
          
          self.instance_variable_set( "@messages", val )
          
        end
        
      end
      
  end
  
end
