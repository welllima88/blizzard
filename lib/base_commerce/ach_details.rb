require 'json'
require_relative 'address.rb'

=begin
  This class represents ACHDetails in the Merchant Application
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class ACHDetails
  
  
def self.xs_payment_to_from_consumer_individuals
	'Consumer / Individuals'
end
 
def self.xs_payment_to_from_businesses_organizations
	'Businesses / Organizations'
end
 
def self.xs_submission_method_manually_via_virtual_terminal
	'Manually via Virtual Terminal'
end
 
def self.xs_submission_method_via_a_gateway
	'Via a Gateway'
end
 
def self.xs_submission_method_through_web_services
	'Through Web Services'
end
 
def self.xs_submission_method_by_batch_submission
	'By Batch Submission'
end
 
def self.xs_submission_method_using_compatible_software
	'Using Compatible Software'
end
 
def self.xs_fees_client_requests_auto_re_presentment_of_nsf_items
	'Auto Re-Presentment of NSF Items'
end
 
def self.xs_fees_client_requests_payer_authentication
	'Payer Authentication'
end
 
def self.xs_fees_client_requests_account_verification
	'Account Verification'
end
 
def self.xs_fees_client_requests_automated_recurring_billing_system
	'Automated Recurring Billing System'
end
 
    
  attr_accessor     :auth_method_conversion_percentage,:auth_method_online_percentage,
    :auth_method_verbal_percentage,:average_monthly_amount,:average_ticket_amount,
    :chargeback_fee,:collections_service_fee,:company_name_descriptor,:descriptor,
    :discount_rate,:issue_credits,:issue_debits,:max_daily_amount,:max_daily_transactions,
    :max_monthly_amount,:max_monthly_transactions,:max_single_transaction_amount,
    :monthly_fee,:monthly_minimum_fee,:payer_auth,:proof_of_auth_fee,:payment_to_from,
    :payment_url,:recurring,:return_fee,:submission_methods,:termination_fee,:transaction_fee,
    :unauth_return,:fees_client_requests,:merchant_reports,:payment_url_2,:url_passwords,
    :has_current_processor,:username,:password,:in_person_signature_percentage,
    :duplicates,:current_processor,:represent_fee,:auth_method_written_in_person_percentage,
    :auth_method_written_faxed_percentage,:fee_other,:payment_url_3,:url_passwords_2,
    :url_passwords_3,:merchant_rep_email,:messages
  

=begin
    Default Constructor
    @author Steven Wright <steven.wright@basecommerce.com>
=end
  def initialize
    @submission_methods = Array.new
    @fees_client_requests = Array.new
    @payment_to_from = Array.new
  end

=begin
  Defines the objects json prefix

  @return the json prefix
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def json_prefix
    :ach_details
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
  Returns a json object representation of the Location
  @params Options any options for modifying the output JSON
  @returns The json representation of this location
  @author Steven Wright <steven.wright@basecommerce.com>
=end

def to_json(options = nil)
      hash = {}
      
      self.instance_variables.each do |var|
        var_text = var[1..-1]
        

        if ( var.is_a? Hash )
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
              
                if var == "@fees_client_requests"

                  val.each{
                    |elem|
                    self.instance_variable_get( "@fees_client_requests" ).push( elem )
                  }

                elsif var == "@submission_methods"

                  val.each{
                    |elem|
                    self.instance_variable_get( "@submission_methods" ).push( elem )
                  }

                elsif var == "@payment_to_from"

                  val.each{
                    |elem|
                    self.instance_variable_get( "@payment_to_from" ).push( elem )
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

  