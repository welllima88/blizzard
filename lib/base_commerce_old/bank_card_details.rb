require 'json'

=begin
  This class represents a Bank Card Details object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class BankCardDetails
  
def self.xs_cardholder_charged_purchase
	'Purchase'
end
 
def self.xs_cardholder_charged_shipment
	'Shipment'
end
 
def self.xs_debit_signature_cards_requested_visa
	'Visa Signature Debit'
end
 
def self.xs_debit_signature_cards_requested_mastercard
	'Mastercard Signature Debit'
end
 
def self.xs_debit_signature_cards_requested_discover
	'Discover Signature Debit'
end
 
def self.xs_other_brands_requested_american_express
	'American Express'
end
 
def self.xs_other_brands_requested_pin_debit
	'Pin Debit'
end
 
def self.xs_other_brands_requested_ebt
	'EBT'
end
 
def self.xs_debit_brands_requested_visa
	'Visa Debit'
end
 
def self.xs_debit_brands_requested_mastercard
	'MasterCard Debit'
end
 
def self.xs_debit_brands_requested_discover
	'Discover Debit'
end
 
def self.xs_credit_signature_cards_requested_visa_credit
	'Visa Credit'
end
 
def self.xs_credit_signature_cards_requested_mastercard_credit
	'MasterCard Credit'
end
 
def self.xs_credit_signature_cards_requested_discover_network_credit
	'Discover Network Credit'
end
 
def self.xs_credit_requested_visa_credit
	'Visa Credit'
end
 
def self.xs_credit_requested_mastercard_credit
	'Mastercard Credit'
end
 
def self.xs_credit_requested_discover_credit
	'Discover Credit'
end
   
  attr_accessor :fee_other,:currently_accept_amex,:amex_average_monthly_volume,:amex_average_ticket_amount,:amex_cap_number,:amex_current_number,
    :amex_max_high_ticket_amount,:amex_max_monthly_volume,:amex_transaction_fee,:avs,:average_monthly_volume,:average_ticket,:batch_settlement,
    :card_present_percentage,:chargeback_fee,:flat_rate,:gateway_access,:gateway_transaction,
    :internet_percentage,:max_ticket,:max_monthly_volume,:mid_qual_rate,:minimum_discount,:monthly_fee,:non_qual_rate,:online_stmt_fee,
    :pci_compliance_monthly,:pass_through_plus,:pin_debit_atm_transaction,:payment_url,:qual_rate,:recurring,:transaction_fee,:wireless_fee,
    :cardholder_charged,:cardholder_data_stored_locally,:debit_signature_cards_requested,:previously_terminated_as_visa_mastercard_merchant,
    :visa_mastercard_signage,:third_party_access_to_cardholder_data,:other_brands_requested,:mail_order_percentage,:telephone_order_percentage,
    :duplicates,:debit_brands_requested,:credit_signature_cards_requested,:credit_requested,:unpaid_item_fee,:authorization_fee,:amex_authorization_fee,:retrieval_fee,
    :messages

=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    @debit_signature_cards_requested = Array.new
    @other_brands_requested = Array.new
    @debit_brands_requested = Array.new
    @credit_signature_cards_requested = Array.new
    @credit_requested = Array.new
    @currently_accept_amex = false
    @recurring = false
    @cardholder_data_stored_locally = false
    @previously_terminated_as_visa_mastercard_merchant = false
    @visa_mastercard_signage = false
    @third_party_access_to_cardholder_data = false
    @duplicates = false
    
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :bank_card_details
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
  Returns a json object representation of the Bank Card Details object
  @params Options any options for modifying the output JSON
  @returns The json representation of this Bank Card Details object
  @author Steven Wright <steven.wright@basecommerce.com>
=end

def to_json(options = nil)
      hash = {}
      
      self.instance_variables.each do |var|
        
        var_text = var[1..-1]
        
        if( var_text == "legal_address")
          
          o_addr = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_addr.to_json
          
        elsif( var_text == "third_party_access_to_cardholder_data" )
          
          hash[get_qualified_key("3rd_party_access_to_cardholder_data")] = self.instance_variable_get var 
          
        elsif( var_text == "credit_requested" )
          
          hash[get_qualified_key(var_text)] = self.instance_variable_get( var )
          
        elsif( var_text == "average_monthly_volume") 
          
          hash[get_qualified_key(var_text)] = self.instance_variable_get( var )
          hash["bank_card_details_average_monthly_voume"] = self.instance_variable_get( var )
            # REMOVE THIS ONCE JAVA MERCHANT APP SDK FIX HAS BEEN APPLIED
            
        elsif( var_text == "average_ticket" )
            
          hash[get_qualified_key(var_text)] = self.instance_variable_get( var )
          hash["bank_card_details_average_ticket_amount"] = self.instance_variable_get( var )
          # IN THE JAVA SDK THIS FIELD SHOULD BE AVERAGE TICKET AMOUNT
          # REMOVE THIS ONCE JAVA MERCHANT APP SDK FIX HAS BEEN APPLIED
          
        elsif( var.is_a? Hash )
            hash[get_qualified_key(var_text)] = var.to_json
            
        else
          
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
          
        end
        
      end
      return hash.to_json
end

=begin
  Builds a Bank Card Details object based off of the JSON input.

  @param vo_json   JSON representation of a Bank Card Details object
  @return  the Bank Card Details object
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(string)
    
      s_prefix = "bank_card_details"
      
      o_addr = Address.new
      
      JSON.load(string).each do |var, val|
        
        if ( var.include? s_prefix )
          
            var = "@" + var[s_prefix.size+1..-1]
            
              
              if( var == "@legal_address" )
                  
                self.instance_variable_set( "@legal_address" ,o_addr.build_from_json( val.to_json ) )
                
              elsif( var == "@average_monthly_voume" )
                # REMOVE THIS ONCE JAVA MERCHANT APP SDK FIX HAS BEEN APPLIED
                self.instnace_variable_set("@average_monthly_voulme", val)
               
              elsif( var == "@average_ticket" )
                self.instance_variable_set( "@average_ticket_amount", val )
                
              elsif( var == "@3rd_party_access_to_cardholder_data" )
                
                self.instance_variable_set("@third_party_access_to_cardholder_data", val )
            
              elsif( var == "@debit_signature_cards_requested" )
                
                val.each{
                    |elem|
                    self.instance_variable_get( "@debit_signature_cards_requested" ).push( elem )
                  }
                  
              elsif( var == "@bank_card_details_other_brands_requested" ) 
                
                val.each{
                    |elem|
                    self.instance_variable_get( "@bank_card_details_other_brands_requested" ).push( elem )
                  }
                  
              elsif ( var == "@bank_card_details_debit_brands_requested" ) 
                
                val.each{
                    |elem|
                    self.instance_variable_get( "@bank_card_details_debit_brands_requested" ).push( elem )
                  }
                  
              elsif ( var == "@bank_card_details_credit_signature_cards_requested" ) 
                
                val.each{
                    |elem|
                    self.instance_variable_get( "@bank_card_details_credit_signature_cards_requested" ).push( elem )
                  }
                  
              elsif ( var == "@bank_card_details_credit_requested" ) 
                
                  val.each{
                    |elem|
                    self.instance_variable_get( "@bank_card_details_credit_requested" ).push( elem )
                  }
                  
              else
                
                  self.instance_variable_set( var, val )
                  
              end

        elsif ( var == "messages" )
          
          self.instance_variable_set( "@messages", val )
          
        end
        
      end
      
  end  
end