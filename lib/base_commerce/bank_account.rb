=begin
  BankAccount is an entity class that defines attributes of a Bank Account.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class BankAccount
  
  # Represents a Bank Account of type Checking
  def self.xs_ba_type_checking
    'CHECKING'
  end
  
  # Represents a Bank Account of type Savings
  def self.xs_ba_type_savings
    'SAVINGS'
  end
  
  # Represents a Bank Accounts status of Active
  def self.xs_ba_status_active  
    'ACTIVE'
  end
  
  # Represents a Bank Accounts status of Deleted
  def self.xs_ba_status_deleted 
    'DELETED'
  end
  
  # Represents a Bank Accounts status of Failed
  def self.xs_ba_status_failed
    'FAILED'
  end

  attr_accessor :name, :alias, :account_number, :routing_number, :token,
    :status, :type, :messages

  # Default Constructor
  def initialize
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def json_prefix
    :bank_account
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
  Returns a JSON representation of the BankAccount

  @return  the JSON representation
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def to_json
      hash = {}

      self.instance_variables.each do |var|
        var_text = var[1..-1]
        if ( var_text == "messages")
          hash[var_text] = self.instance_variable_get var
        else
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
      end
      hash.to_json
  end

=begin
  Builds and Returns an BankAccount object based off of the JSON input.

  @param vo_json   JSON representation of an BankAccount
  @return  the BankAccount
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def build_from_json(string)
    JSON.load(string).each do |var, val|
      if ( var.include? "bank_account" )
        var = "@" + var[13..-1]
        self.instance_variable_set(var, val)
        if ( val.is_a? Hash and val.include? "bank_account_status_name" ) 
          JSON.load(val.to_json).each do |status_var, status_val|
            if ( status_var == "bank_account_status_name" )
              self.instance_variable_set("@status", status_val)
            end
          end
        end
      elsif ( var == "messages" )
        self.instance_variable_set("@messages", val)
      end
    end
  end
  
end
