require "date"

=begin
  BankAccountTransaction is an entity class that defines attributes of a Bank Account Transaction.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class BankAccountTransaction
  
  # Represents a transaction where the account type used is a Checking account.
  def self.xs_bat_account_type_checking 
    'CHECKING'
  end
  
  # Represents a transaction where the account type used is a Savings account.
  def self.xs_bat_account_type_savings  
    'SAVINGS'
  end
  
  # Represents a transaction that is of type Credit.
  def self.xs_bat_type_credit
    'CREDIT'
  end
  
  # Represents a transaction that is of type Debit.
  def self.xs_bat_type_debit
    'DEBIT'
  end
  
  # Represents a transaction that is of type Reversal.
  def self.xs_bat_type_reversal
    'REVERSAL'
  end
  
  # Represents a transaction that is of type Cancel.
  def self.xs_bat_type_cancel
    'CANCEL'
  end
  
  # Represents a transaction whose status is Created.
  def self.xs_bat_status_created
    'CREATED'
  end
  
  # Represents a transaction whose status is Initiated.
  def self.xs_bat_status_initiated
    'INITIATED'
  end
  
  # Represents a transaction whose status is Settled.
  def self.xs_bat_status_settled
    'SETTLED'
  end
  
  # Represents a transaction whose status is Returned.
  def self.xs_bat_status_returned
    'RETURNED'
  end
  
  # Represents a transaction whose status is Canceled.
  def self.xs_bat_status_canceled
    'CANCELED'
  end
  
  # Represents a transaction whose status is Failed.
  def self.xs_bat_status_failed
    'FAILED'
  end
  
  # Represents a transaction whose status is Rejected.
  def self.xs_bat_status_rejected
    'REJECTED'
  end
  
  # Represents a transaction whose method is CCD.
  def self.xs_bat_method_ccd
    'CCD'
  end
  
  # Represents a transaction whose method is PPD.
  def self.xs_bat_method_ppd
    'PPD'
  end
  
  # Represents a transaction whose method is TEL.
  def self.xs_bat_method_tel
    'TEL'
  end
  
  # Represents a transaction whose method is WEB.
  def self.xs_bat_method_web
    'WEB'
  end
  
  attr_accessor :id, :type, :status, :method,
    :account_type, :routing_number, :account_number, :account_name,
    :return_code, :trace, :merchant_transaction_id, :token,
    :micr_data, :amount, :effective_date, :settlement_date, :return_date,
    :recurring_indicator, :custom_field1, :custom_field2, :custom_field3,
    :custom_field4, :custom_field5, :custom_field6, :custom_field7,
    :custom_field8, :custom_field9, :custom_field10, :messages
  
  # Default Constructor
  def initialize
    @messages = Array.new
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def json_prefix
    :bank_account_transaction
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
  Returns a JSON representation of the BankAccountTransaction

  @return  the JSON representation
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def to_json
      hash = {}

      self.instance_variables.each do |var|
        var_text = var[1..-1]
        if ( var_text == "return_date" || var_text == "settlement_date" || var_text == "effective_date" )
          o_date = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_date.strftime( "%m/%d/%Y %H:%M:%S" )
        elsif ( var_text == "messages" )
          hash[var_text] = self.instance_variable_get var
        elsif ( var_text == "token" )
          hash["bank_account_token"] = self.instance_variable_get var
        else
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
      end
      hash.to_json
  end
  
=begin
  Builds and Returns an BankAccountTransaction object based off of the JSON input.

  @param vo_json   JSON representation of an BankAccountTransaction
  @return  the BankAccountTransaction
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def build_from_json(string)

      JSON.load(string).each do |var, val|
        if ( var.include? "bank_account_transaction" )
          var = "@" + var[25..-1]
          
          if ( val.is_a? Hash and val.include? "bank_account_transaction_status_name" )
            JSON.load(val.to_json).each do |status_var, status_val|
              if ( status_var == "bank_account_transaction_status_name" )
                self.instance_variable_set("@status", status_val)
              end
            end
          elsif ( val.is_a? Hash and val.include? "bank_account_transaction_method_name" ) 
            JSON.load(val.to_json).each do |status_var, status_val|
              if ( status_var == "bank_account_transaction_method_name" )
                self.instance_variable_set("@method", status_val)
              end
            end
          elsif ( val.is_a? Hash and val.include? "bank_account_transaction_type_name" ) 
            JSON.load(val.to_json).each do |status_var, status_val|
              if ( status_var == "bank_account_transaction_type_name" )
                self.instance_variable_set("@type", status_val)
              end
            end
          elsif ( val.is_a? Hash and val.include? "bank_account_transaction_account_type_name" ) 
            JSON.load(val.to_json).each do |status_var, status_val|
              if ( status_var == "bank_account_transaction_account_type_name" )
                self.instance_variable_set("@account_type", status_val)
              end
            end
          elsif ( var == "@return_date" || var == "@settlement_date" || var == "@effective_date" )
            o_date = DateTime.strptime(val, "%m/%d/%Y %H:%M:%S" )
            self.instance_variable_set(var, o_date)
          else
            self.instance_variable_set(var, val)
          end
        elsif ( var == "messages")
          self.instance_variable_set("@messages", val)
        end
      end
  end
  
end
