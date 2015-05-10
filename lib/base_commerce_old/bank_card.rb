require_relative "address.rb"
require "date"

=begin
  BankCard is an entity class that defines attributes of a Bank Card.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class BankCard
  
  # Represents a Bank Cards status of Active
  def self.xs_bc_status_active  
    'ACTIVE'
  end
  
  # Represents a Bank Cards status of Deleted
  def self.xs_bc_status_deleted
    'DELETED'
  end
  
  # Represents a Bank Cards status of Failed
  def self.xs_bc_status_failed
    'FAILED'
  end

  attr_accessor :name, :number, :alias, :expiration_month, :expiration_year,
      :status, :billing_address, :token, :creation_date, :last_used_date, :messages
  
  # Default Constructor  
  def initialize
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def json_prefix
    :bank_card
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
  Returns a JSON representation of the BankCard

  @return  the JSON representation
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def to_json
      hash = {}

      self.instance_variables.each do |var|
        var_text = var[1..-1]
        if ( var_text == "billing_address" )
          o_address = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_address.to_json
        elsif ( var_text == "creation_date" || var_text == "last_used_date" )
          o_date = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_date.strftime( "%m/%d/%Y %H:%M:%S" )
        elsif ( var_text == "messages")
          hash[var_text] = self.instance_variable_get var
        else
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
      end
      hash.to_json
  end
  
=begin
  Builds and Returns an BankCard object based off of the JSON input.

  @param vo_json   JSON representation of an BankCard
  @return  the BankCard
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def build_from_json(string)
      JSON.load(string).each do |var, val|
        if ( var.include? "bank_card" )
          var = "@" + var[10..-1]
          if ( val.is_a? Hash and val.include? "bank_card_status_name" ) 
            JSON.load(val.to_json).each do |status_var, status_val|
              if ( status_var == "bank_card_status_name" )
                self.instance_variable_set("@status", status_val)
              end
            end
          elsif ( var == "@billing_address" )
            o_address = Address.new
            o_address.build_from_json( val.to_json )
            self.instance_variable_set(var, o_address)
          elsif ( var == "@creation_date" || var == "@last_used_date" )
            o_date = DateTime.strptime(val, "%m/%d/%Y %H:%M:%S" )
            self.instance_variable_set(var, o_date)
          else
            self.instance_variable_set(var, val)
          end
        elsif ( var == "messages" )
          self.instance_variable_set("@messages", val)
        end
      end
  end
  
end
