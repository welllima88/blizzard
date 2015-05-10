require_relative "settlement_batch.rb"
require_relative "bank_account_transaction.rb"

=begin
  PushNotification is an entity class that defines attributes of a Push Notification.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
  @author Steven Wright <steven.wright@basecommerce.com>
=end
class PushNotification
  
  # Represents a push notification of type ACH change
  def self.xs_pn_ach_change 
    'ACH CHANGE'
  end
  
  # Represents a push notification of type settlement batch change
  def self.xs_pn_settlement_batch_change
    'SETTLEMENT BATCH CHANGE'
  end
  
  # Represents the string "PING" used in Ping - Pong messages
  def self.xs_pn_type_ping
    'PING'
  end
  
  # Represents the string "JSON" used in generic messages
  def self.xs_pn_type_json
    'JSON'
  end
  
  attr_accessor :type, :settlement_batch, :bank_account_transaction, :id
  
  # Default Constructor
  def initialize
  end
  
=begin
  Checks to see if the notification is a certain type
     
  @param vs_type the notification type being checked
  @return true if they are the same otherwise false
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def is_notification( vs_type )
    self.type == vs_type
  end
  
=begin
  Defines the objects json prefix

  @return the json prefix
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def json_prefix
    :push_notification
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
  Sets the is_type to PushNotification.xs_pn_type_ping

  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def set_ping
    self.type = PushNotification.xs_pn_type_ping
  end 
  
=begin
  Returns a JSON representation of the PushNotification

  @return  the JSON representation
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def to_json
      hash = {}

      self.instance_variables.each do |var|
        var_text = var[1..-1]
        if ( var_text == "settlement_batch" )
          o_sb = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_sb.to_json
        elsif ( var_text == "bank_account_transaction" )
          o_bat = self.instance_variable_get(var)
          hash[get_qualified_key(var_text)] = o_bat.to_json
        else
          hash[get_qualified_key(var_text)] = self.instance_variable_get var
        end
      end
      hash.to_json
  end
  
=begin
  Builds a PushNotification object based off of the JSON input.
  The caller is set to the new PN object, nothing is returned

  @param vo_json   JSON representation of an PushNotification
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
  @author Steven Wright <steven.wright@basecommerce.com>
=end
  def build_from_json(string)
      JSON.load(string).each do |var, val|
        if( var.include? "push_notification" )
            var = "@" + var[18..-1]
            if ( var == "@settlement_batch" )

              o_sb = SettlementBatch.new

              o_sb.build_from_json( val )

              self.instance_variable_set(var, o_sb)

            elsif ( var == "@bank_account_transaction" )

              o_bat = BankAccountTransaction.new

              o_bat.build_from_json( val )

              self.instance_variable_set(var, o_bat)

            elsif ( var == "@type" && val == "PING")

                 self.instance_variable_set( var, PushNotification.xs_pn_type_ping )

            else
              
              self.instance_variable_set(var, val)
              
            end
            
        end
        
      end
  end
  
end
