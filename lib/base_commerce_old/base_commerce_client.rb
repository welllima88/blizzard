require 'net/http'
require_relative 'triple_des_service.rb'

=begin
  BaseCommerceClient is a utility class that handles all of the client side work for creating and sending the request, as well as formatting and returning the response to the user.

  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
class BaseCommerceClient
  

  @@xs_url = 'https://gateway.basecommerce.com'
  @@xs_sandbox_url = 'https://gateway.basecommercesandbox.com'

  
  attr_reader :username, :password, :key
  attr_accessor :sandbox
  
=begin
  Constructor for the Client

  @param vs_username the users SDK username
  @param vs_password the users SDK password
  @param vs_key the users SDK key
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def initialize( vs_username, vs_password, vs_key )
    @username = vs_username
    @password = vs_password
    @key = vs_key
    @sandbox = false
  end
  
=begin
  Add a bank account to the system. 
  The returned BankAccount will have a token that can be used on future bank account transactions instead of passing the bank account data.

  @param vo_bank_account    the bank account 
  @return  the updated bank account transaction
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def add_bank_account(vo_bank_account)
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => encrypt_payload(vo_bank_account.to_json ) }.to_json

    decrypted_response = do_post( "/pcms/?f=API_addBankAccountV4", o_data )
    
    o_bank_account = nil
    o_exception = nil
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "bank_account" )
            o_bank_account = BankAccount.new
            o_bank_account.build_from_json( val.to_json )
          elsif ( var == "exception" )
            o_exception = Array.new
            JSON.load(val.to_json).each do |exception_var, exception_val|
              o_exception.push( exception_val )
            end
          end
      end
      
      if ( !o_exception.nil? )
        o_bank_account.messages = o_exception
      end
      
    return o_bank_account

  end
  
=begin
  Add a bank card to the system. 
  The returned BankCard will have a token that can be used on future bank card transactions instead of passing the card data.

  @param vo_bank_card    the bank card 
  @return  the updated bank card 
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def add_bank_card(vo_bank_card)
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => encrypt_payload(vo_bank_card.to_json ) }.to_json

    decrypted_response = do_post( "/pcms/?f=API_addBankCardV4", o_data )

    o_bank_card = nil
    o_exception = nil
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "bank_card" )
            o_bank_card = BankCard.new
            o_bank_card.build_from_json( val.to_json )
          elsif ( var == "exception" )
            o_exception = Array.new
            JSON.load(val.to_json).each do |exception_var, exception_val|
              o_exception.push( exception_val )
            end
          end
      end
      
      if ( !o_exception.nil? )
        o_bank_card.messages = o_exception
      end
      
    return o_bank_card

  end

=begin
  Processes the bank account transaction using the specified BankAccountTransaction.
  Returns an updated BankAccountTransaction containing the response information.
   
  @param vo_bat    the bank account transaction
  @return  the updated bank account transaction
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def process_bank_account_transaction(vo_bat)
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => encrypt_payload(vo_bat.to_json ) }.to_json

    decrypted_response = do_post( "/pcms/?f=API_processBankAccountTransactionV4", o_data )

    o_bat = nil
    o_exception = nil
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "bank_account_transaction" )
            o_bat = BankAccountTransaction.new
            o_bat.build_from_json( val.to_json )
          elsif ( var == "exception" )
            o_exception = Array.new
            JSON.load(val.to_json).each do |exception_var, exception_val|
              o_exception.push( exception_val )
            end
          end
      end
      
      if ( !o_exception.nil? )
        o_bat.messages = o_exception
      end
      
    return o_bat

  end
  
=begin
  Processes the transaction using the specified BankCardTransaction.
  Returns an updated BankCardTransaction containing the response information.

  @param vo_bct    the bank card transaction
  @return  the updated bank card transaction
  @author Ryan Murphy <ryan.murphy@basecommerce.com>     
=end
  def process_bank_card_transaction(vo_bct)
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => encrypt_payload(vo_bct.to_json ) }.to_json

    decrypted_response = do_post( "/pcms/?f=API_processBankCardTransactionV4", o_data )

    o_bct = nil
    o_exception = nil
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "bank_card_transaction" )
            o_bct = BankCardTransaction.new
            o_bct.build_from_json( val.to_json )
          elsif ( var == "exception" )
            o_exception = Array.new
            JSON.load(val.to_json).each do |exception_var, exception_val|
              o_exception.push( exception_val )
            end
          end
      end
      
      if ( !o_exception.nil? )
        o_bct.messages = o_exception
      end
      
    return o_bct

  end

=begin
  Returns a BankCardTransaction associated with the Bank Card Transaction ID passed in
 
  @param vn_id the id of the bank card transaction you want returned
  @return the Bank Card Transaction
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def get_bank_card_transaction(vn_id)
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => vn_id }.to_json

    decrypted_response = do_post( "/pcms/?f=API_getBankCardTransactionV4", o_data )

    o_bct = nil
    o_exception = nil
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "bank_card_transaction" )
            o_bct = BankCardTransaction.new
            o_bct.build_from_json( val.to_json )
          elsif ( var == "exception" )
            o_exception = Array.new
            JSON.load(val.to_json).each do |exception_var, exception_val|
              o_exception.push( exception_val )
            end
          end
      end
      
      if ( !o_exception.nil? )
        o_bct.messages = o_exception
      end
      
    return o_bct

  end
  
=begin
  Returns a BankAccountTransaction associated with the Bank Account Transaction ID passed in
 
  @param vn_id the id of the bank account transaction you want returned
  @return the Bank Account Transaction
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def get_bank_account_transaction(vn_id)
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => vn_id }.to_json
    
    decrypted_response = do_post( "/pcms/?f=API_getBankAccountTransactionV4", o_data )
    
    o_bat = nil
    o_exception = nil
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "bank_account_transaction" )
            o_bat = BankAccountTransaction.new
            o_bat.build_from_json( val.to_json )
          elsif ( var == "exception" )
            o_exception = Array.new
            JSON.load(val.to_json).each do |exception_var, exception_val|
              o_exception.push( exception_val )
            end
          end
      end
      
      if ( !o_exception.nil? )
        
        o_bat.messages = o_exception
      end
      
    return o_bat

  end

=begin
    Pings the server to make sure the connection is alive

    @return true if the user connects to the servers with their credentials, false otherwise
    @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def send_ping()
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => encrypt_payload( {"PING" => "PING"}.to_json ) }.to_json

    decrypted_response = do_post( "/pcms/?f=API_PingPong", o_data )
    
    o_bank_account = nil
    o_exception = nil
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "success" )
            return true;
          end
      end
      
    return false

  end  

=begin
  Creates a push notification from the passed in string
   
  @param vs_pn    the push notification string
  @return  the push notification
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def handle_push_notification(vs_pn)
    
    o_decrypted_json = decrypt_payload_to_json(vs_pn)
    
    s_type = o_decrypted_json['push_notification_type']
    
    if ( s_type == 'JSON' ) 
    
      o_json_pn = JSONPushNotification.new
      o_json_pn.build_from_json( o_decrypted_json )
      return o_json_pn
      
    else
      
      o_pn = PushNotification.new
      o_pn.build_from_json( o_decrypted_json )
      return o_pn
      
    end
  end
  
=begin
  Sets the push notification url associated with your account.
 
  @param vs_url The push notification url you would like associated with your account
  @return Returns a string, value will be "success" if the url was accepted or "URL must start with https" if the url was not accepted.
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def set_push_notification_url(vs_url)
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, "payload" => encrypt_payload( {'url' => vs_url }.to_json ) }.to_json
    
    decrypted_response = do_post( "/pcms/?f=API_setPushNotificationURLV4", o_data )
    
    JSON.load(decrypted_response).each do |var, val|
          if ( var == "success" )
            return val
          elsif ( var == "exception" )
            JSON.load(val.to_json).each do |exception_var, exception_val|
              return exception_val
            end
          end
      end
      
  end
  
=begin
  Submit a merchant application.
  
  @param vo_merch_app the merchant_application
  @return the list of created merchant applications
  @author Steven Wright <steven.wright@basecommerce.com>
=end  
  def submit_application ( vo_merch_app )
    
    o_returned_applications = Array.new
    o_query = {'gateway_username' => @username, 'gateway_password' => @password, 'payload' => encrypt_payload(vo_merch_app.to_json ) }.to_json
    
    response  = self.do_post( "/pcms/?f=newSubmitApplication", o_query )
    
    JSON.load( response ).each do |var|
    
            o_ma = MerchantApplication.new
            o_ma.build_from_json( var.to_json )
            o_returned_applications.push( o_ma )
 
        
    end
      
    
    return o_returned_applications
  end
=begin
  Performs an HTTPS POST request with the given json data to either the sandbox url or production url with the appended function url passed in.

  @param vs_url the function url to post to
  @param vo_data json data that is to be sent to the server
  @return the decrypted response in json from the server
  @author Ryan Murphy <ryan.murphy@basecommerce.com>
=end
  def do_post(vs_url, vo_data)
    
    if ( @sandbox )
      uri = URI.parse( @@xs_sandbox_url )
    else
      uri = URI.parse( @@xs_url )
    end
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Post.new(vs_url)
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', '*/*')
    request.add_field('User-Agent', 'BaseCommerceClientRUBY/4.1.3')
    request.body = vo_data

    response = http.request(request)
    
    if ( response.code == "403" ) 
      raise "Invalid Credentials"
    elsif ( response.code == "404" )
      raise "Invalid url or host is offline"
    elsif ( response.code == "500" )
      raise "Internal Server Error. Please contact tech support"
    end
    
    return decrypt_payload_to_json( response.body );
  end
  
  def decrypt_payload_to_json(data, root_key = nil)
    tripledes = TripleDESService.new(@key)
    decrypted_data = tripledes.decrypt(data)

    unless root_key.nil?
      hash = JSON.parse(decrypted_data)
      unless hash.key?(root_key.to_s)
        decrypted_data = { root_key.to_sym => hash }.to_json
      end
    end

    return decrypted_data
  end

  def encrypt_payload(json)
    tripledes = TripleDESService.new(@key)
    output = tripledes.encrypt(json)
    return output
  end
  
=begin
     Sends a request as a JSON object to the server to be processed and returns the response as a JSON object.
     The passed in JSON object will be encrypted before being sent. The JSON returned
     from the server will be decrypted before being returned.
     
     @param   vo_json A JSON object containing the request type and payload data
     @return  the server response.
     @author  Steven Wright <steven.wright@basecommerce.com> 
=end
  def process_request( vo_json )
    
    hash = JSON.parse( vo_json )
    
    o_data = {'gateway_username' => @username, 'gateway_password' => @password, 'payload' => encrypt_payload( vo_json ) }.to_json

    o_response = do_post( "/pcms/?f=API_processRequest", o_data )
  
    return o_response
    
  end  
  
end
