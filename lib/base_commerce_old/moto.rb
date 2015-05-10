=begin
  This class represents a MOTO object in the Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class Moto

  
def self.xs_processing_method_key_entered_terminal
	'Key Entered Terminal'
end
 
def self.xs_processing_method_virtual_terminal_gateway
	'Virtual Terminal / Gateway'
end
 
def self.xs_order_forms_destroyed
	'Destroyed'
end
 
def self.xs_order_forms_retained
	'Retained'
end
 
def self.xs_outbound_marketing_catalog
	'Catalog'
end
 
def self.xs_outbound_marketing_envelope
	'Envelope'
end
 
def self.xs_outbound_marketing_post_card
	'Post Card'
end
 
def self.xs_outbound_marketing_print_ad
	'Print Ad'
end
 
def self.xs_outbound_marketing_other
	'Other'
end
 

  attr_accessor :processing_method, :order_forms, :software_retain, :outbound_marketing, :outbound_telemarketing_is_conducted

=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    @processing_method = Array.new
    @outbound_marketing = Array.new
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :moto
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
  Returns a json object representation of the MOTO object
  @params Options any options for modifying the output JSON
  @returns The json representation of this MOTO object
  @author Steven Wright <steven.wright@basecommerce.com>
=end

def to_json(options = nil)
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
  Builds and Returns an ACH Details object based off of the JSON input.

  @param vo_json   JSON representation of an ACH Details object
  @return  the ACH Details object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
   def build_from_json(string)
    
      s_prefix = "ach_details"
      
      JSON.load(string).each do |var, val|
        
        if ( var.include? s_prefix )
          
            var = "@" + var[s_prefix.size+1..-1]
            
            if ( val.is_a? Array )
              
                if var == "@processing_methods"

                  val.each{
                    
                    |elem| self.instance_variable_get( "@processing_methods" ).push( elem ) 
                  }

                elsif var == "@outbound_marketing"

                  val.each{ 
                    
                    |elem| self.instance_variable_get( "@outbound_marketing" ).push( elem )
                  }

                end              
              
            else            
              
              self.instance_variable_set( var, val )
              
            end

        elsif ( var == "messages" )
          
          self.instance_variable_set( "@messages", val )
          
        end
        
      end
      
  end
    
end
