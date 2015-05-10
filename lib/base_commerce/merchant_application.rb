require_relative 'location.rb'
require_relative 'account.rb'

=begin
  This class represents a Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class MerchantApplication
  
  attr_accessor :account, :locations, :response_messages, :response_code, :api_version,
    :key, :id, :code, :salesforce_id,:messages

=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    @locations = Array.new
    @response_messages = Hash.new
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :merchant_application
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
  Returns a json object representation of the Merchant Application
  @params Options any options for modifying the output JSON
  @returns The json representation of this Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end

def to_json(options = nil)
      hash = {}
      
      self.instance_variables.each do |var|
        var_text = var[1..-1]
        
        if ( var.is_a? Hash and var_text == "response_messages" )
          o_resp_messages = self.instance_variable_get( var )
          
          hash[get_qualified_key(var_text)] = JSON.generate( o_resp_messages )
        elsif ( var_text == "locations" )
          
          o_locs = self.instance_variable_get( "@locations" )
          hash[get_qualified_key(var_text)] = o_locs
        else
          
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
        
      end
      
      return hash.to_json
end  
=begin
  Builds and Returns a Merchant Application object based off of the JSON input.

  @param vo_json   JSON representation of a Merchant Application object
  @return  the Merchant Application Object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(vo_json)
    
    s_prefix = "merchant_application"
    
    JSON.load(vo_json).each do |var, val|

          if ( var.include? s_prefix )

            var = "@" + var[s_prefix.size+1..-1]
            
            if ( var == "@account" )
              
                o_acct = Account.new
                self.instance_variable_set( "@account", o_acct.build_from_json( val.to_json ) )
                
                  
            elsif ( var == "@locations" )
              
               val.each{ |elem| self.instance_variable_get("@locations").push( elem ) } 
            
            elsif ( var == "@response_messages" )
              
              val.each{ |key,elem|
                
                self.instance_variable_get("@response_messages")[key] = elem }
              
            else
              
              self.instance_variable_set( var , val )
              
            end
            
          elsif ( var == "messages" )

            self.instance_variable_set( "@messages", val )

          end
        
    end
    
  end
  
end
