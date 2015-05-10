
=begin
  This class represents a POS object in the Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class POS
  
  
def self.xs_type_gateway
	'Gateway'
end
 
def self.xs_type_encryption
	'Encryption'
end
 
def self.xs_type_software
	'Software'
end
 
  attr_accessor :vendor_name,:make,:model,:vendor_contact_name,:version,:type,:vendor_phone_number

=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    
  end

=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :pos
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
  Returns a JSON representation of the POS object

  @return  the JSON representation of the POS object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def to_json
      hash = {}

      self.instance_variables.each do |var|
        var_text = var[1..-1]
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
      end
      return hash.to_json
  end
  
=begin
  Builds and Returns A POS object based off of the JSON input.

  @param vo_json   JSON representation of a POS object 
  @return  the POS object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(string)
    
    s_prefix = "pos"
      
      JSON.load(string).each do |var, val|
        
        if ( var.include? s_prefix )
          
            var = "@" + var[s_prefix.size+1..-1]
            
            self.instance_variable_set( var, val )

        elsif ( var == "messages" )
          
          self.instance_variable_set( "@messages", val )
          
        end
        
      end
      
  end  

end
