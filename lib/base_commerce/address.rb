require 'json'

=begin
  Address is a simple re-usable entity class that defines attributes of a postal Address.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class Address
  
  # Represents a home address.
  def self.xs_address_name_home
    "HOME"
  end
  
  # Represents a word address.
  def self.xs_address_name_work
    "WORK"
  end
  
  # Represents a mailing address.
  def self.xs_address_name_mailing
    "MAILING"
  end
  
  # Represents a shipping address.
  def self.xs_address_name_shipping
    "SHIPPING"
  end
  
  # Represents a billing address.
  def self.xs_address_name_billing
    "BILLING"
  end
  
  # Represents a dba address.
  def self.xs_address_name_dba
    "DBA"
  end
  
  # Represents a legal address.
  def self.xs_address_name_legal
    "LEGAL"
  end
  
  attr_accessor :name, :line1, :line2, :line3, :city, :state, :zipcode,
    :country
  
=begin
  Constructor for the Address that takes a name.

  @param vs_name   The type of Address this object refers to. Use one of the static Strings from this class to populate this field
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def initialize(vs_name = nil)
    @name = vs_name unless vs_name.nil?
  end

=begin
  Defines the objects json prefix

  @return the json prefix
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def json_prefix
    :address
  end
  
=begin
  Updates the key with the objects json prefix

  @return the updated json key
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def get_qualified_key(key)
      "#{json_prefix}_#{key}".to_sym
  end
  
=begin
  Returns a JSON representation of the Address

  @return  the JSON representation
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def to_json(options = nil)
      hash = {}

      self.instance_variables.each do |var|
        var_text = var[1..-1]
        hash[get_qualified_key(var_text)] = self.instance_variable_get var
      end
      return hash
  end
  
=begin
  Builds and Returns an Address object based off of the JSON input.

  @param vo_json   JSON representation of an address
  @return  the Address
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def build_from_json(string)
      JSON.load(string).each do |var, val|
          var = "@" + var[8..-1]
          self.instance_variable_set(var, val)
      end
  end
    
end
