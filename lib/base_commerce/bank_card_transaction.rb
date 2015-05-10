require_relative "address.rb"
require "date"

=begin
  BankCardTransaction is an entity class that defines attributes of a Bank Card Transaction.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class BankCardTransaction
  
    # Represents an authorization transaction.
    def self.xs_bct_type_auth     
      'AUTH'
    end
    
    # Represents an sale transaction.
    def self.xs_bct_type_sale     
      'SALE'
    end
    
    # Represents an void transaction.
    def self.xs_bct_type_void     
      'VOID'
    end
    
    # Represents an capture transaction.
    def self.xs_bct_type_capture  
      'CAPTURE'
    end
    
    # Represents an refund transaction.
    def self.xs_bct_type_refund   
      'REFUND'
    end
    
    # Represents an credit transaction.
    def self.xs_bct_type_credit   
      'CREDIT'
    end
  
    # Represents a transaction whose status is created.
    def self.xs_bct_status_created 
      'CREATED'
    end
    
    # Represents a transaction whose status is authorized.
    def self.xs_bct_status_authorized 
      'AUTHORIZED'
    end
    
    # Represents a transaction whose status is captured.
    def self.xs_bct_status_captured 
      'CAPTURED'
    end
    
    # Represents a transaction whose status is settled.
    def self.xs_bct_status_settled 
      'SETTLED'
    end
    
    # Represents a transaction whose status is voided.
    def self.xs_bct_status_voided 
      'VOIDED'
    end
    
    # Represents a transaction whose status is declined.
    def self.xs_bct_status_declined 
      'DECLINED'
    end
    
    # Represents a transaction whose status is failed.
    def self.xs_bct_status_failed 
      'FAILED'
    end
    
    # Represents a transaction whose status is waiting for verification.
    def self.xs_bct_status_3dsecure 
      '3DSECURE'
    end
    
    # Represents a transactions whose status is verification complete.
    def self.xs_bct_status_verified 
      'VERIFIED'
    end
  

  attr_accessor :billing_address, :type, :card_number, :card_name,
    :card_expiration_month, :card_expiration_year, :card_cvv2, :card_track1_data,
    :card_track2_data, :ip_address, :po_number, :authorization_code,
    :response_code, :status, :response_message, :cvv_response_code,
    :avs_response_code, :encrypted_track_data, :merchant_transaction_id,
    :verify_complete_url, :verify_url, :amount, :tax_amount, :tip_amount,
    :id, :settlement_batch_id, :check_secure_code, :recurring_indicator,
    :token, :settlement_date, :messages, :creation_date, :custom_field1, 
    :custom_field2, :custom_field3, :custom_field4, :custom_field5, 
    :custom_field6, :custom_field7, :custom_field8, :custom_field9, :custom_field10

  # Default Constructor
  def initialize
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def json_prefix
    :bank_card_transaction
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
  Returns a JSON representation of the BankCardTransaction

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
        elsif ( var_text == "creation_date" || var_text == "settlement_date" )
          o_date = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_date.strftime( "%m/%d/%Y %H:%M:%S" )
        elsif ( var_text == "messages" )
          hash[var_text] = self.instance_variable_get var
        elsif ( var_text == "card_name" )
          hash[get_qualified_key("name")] = self.instance_variable_get var
        elsif ( var_text == "card_expiration_month" )
          hash[get_qualified_key("expiration_month")] = self.instance_variable_get var
        elsif ( var_text == "card_expiration_year" )
          hash[get_qualified_key("expiration_year")] = self.instance_variable_get var
        elsif ( var_text == "id" )
            hash[get_qualified_key("id")] = self.instance_variable_get var
        elsif ( var_text == "token" )
            hash["token"] = self.instance_variable_get var
        else
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
      end
      hash.to_json
  end
  
=begin
  Builds and Returns an BankCardTransaction object based off of the JSON input.

  @param vo_json   JSON representation of an BankCardTransaction
  @return  the BankCardTransaction
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def build_from_json(string)
      JSON.load(string).each do |var, val|
        if ( var.include? "bank_card_transaction" )
          var = "@" + var[22..-1]

          if ( val.is_a? Hash and val.include? "bank_card_transaction_status_name" )
            JSON.load(val.to_json).each do |status_var, status_val|
              if ( status_var == "bank_card_transaction_status_name" )
                self.instance_variable_set("@status", status_val)
              end
            end
          elsif ( val.is_a? Hash and val.include? "bank_card_transaction_type_name" ) 
            JSON.load(val.to_json).each do |status_var, status_val|
              if ( status_var == "bank_card_transaction_type_name" )
                self.instance_variable_set("@type", status_val)
              end
            end
          elsif ( var == "@billing_address" )
            o_address = Address.new
            o_address.build_from_json( val.to_json )
            self.instance_variable_set(var, o_address)
          elsif ( var == "@creation_date" || var == "@settlement_date" )
            o_date = DateTime.strptime(val, "%m/%d/%Y %H:%M:%S" )
            self.instance_variable_set(var, o_date)
          elsif ( var == "@transaction_id" )
            self.instance_variable_set("@id", val)
          else 
            self.instance_variable_set(var, val)
          end
        elsif ( var == "messages")
          self.instance_variable_set("@messages", val)
        end
      end
  end
  
end
