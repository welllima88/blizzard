class PaymentApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token

  #
  # Credit Card Processing
  #    

        # Transaction Type

      
        def credit_card_payment
          # Verify API Token
          company = Company.first(:api_token => params[:api_token])
          if !company
            return false
          end
        
          # Post/Get/Parse Requirements
          require 'open-uri'
          require 'net/https'
          require 'nokogiri'
          require 'uri'
  
          # General Variables
          vendor = "Evendra"
          store = Store.find(params[:store_id])
  
          # Transaction Variables
          transaction_type = "Sale"
          invoice_number = params[:orderId]
          amount = params[:payment_amount]
  
          # Card Variables
          magdata = params[:magdata]
          origionalMagData = params[:magdata]
          cardData = format_credit_card(magdata, params[:card_number], params[:exp], params[:name], params[:cvv])
  
          # Get GatewayInformation
          post_url = gatewayUrl(store.gateway, store.gateway_status)
          post_parameters = gatewaySpec(store.gateway, post_url, store.gateway_username, store.gateway_password, store.gateway_storename, transaction_type, cardData, invoice_number, amount, '', '', '', params[:register_id], origionalMagData)
        
          @uri = URI.parse("#{post_url}")

          # Full control
          @http = Net::HTTP.new(@uri.host, @uri.port)
          @http.use_ssl = true
          @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          if store.gateway == 'MerchantWarehouse'
            @request = Net::HTTP::Post.new(@uri.request_uri, { 'Content-Type' => 'text/xml; charset=utf-8' })
          else
            @request = Net::HTTP::Post.new(@uri.request_uri)
          end
          @request.body = post_parameters
        
          #puts "URI #{@uri.request_uri}, Params: #{post_parameters}"
        
          @response = @http.request(@request)
        
        
          x = REXML::Document.new Nokogiri.XML(@response.body).to_s
        
          #xputs "RESPONSE: #{x}"
  
          # Parse Transaction Response
          json_response = parseGatewayResponse(x, store.gateway, cardData['card_last_four'], "#{cardData['expiration_month']}#{cardData['expiration_year']}", amount, 'Sale')
        
          # Respond To App
          respond_to do |format|
            format.json { render :text => json_response }
          end
        
        end
      
        # Refund Credit Card
   
        def refund_credit_card
        
          # Verify API Token
          company = Company.first(:api_token => params[:api_token])
          if !company
            return false
          end

          # General Variables
          transaction_type = "Void"
          store = Store.find(params[:storeId])
          amount = params[:refundAmount].to_f
          cardData = format_credit_card('', '', '', '', '')
          transaction_id = params[:transaction_id]
        
          # Get Payment Information For Returns
          if !params[:orderId].blank?
            order_payment = Order.find(params[:orderId]).order_payments.select{|p| p.id.to_s == params[:orderPaymentId].to_s}[0]
            # Transaction Variables
            transaction_id = order_payment.transaction_id
            if params[:refundAmount].to_f >= order_payment.amount.to_f
              amount = order_payment.amount.to_f
            else
              transaction_type = "Return"
            end
          end
        
          # First Try (Void)
          post_url = gatewayUrl(store.gateway, store.gateway_status)
          post_parameters = gatewaySpec(store.gateway, post_url, store.gateway_username, store.gateway_password, store.gateway_storename, transaction_type, cardData, params[:orderId], amount, transaction_id, '', '', nil, nil)
         # old post_parameters = gatewaySpec(store.gateway, post_url, store.gateway_username, store.gateway_password, store.gateway_storename, transaction_type, cardData, params[:orderId], amount, transaction_id, nil, nil)
        
          # Get Transaction Response          
          @uri = URI.parse("#{post_url}")

          # Full control
          @http = Net::HTTP.new(@uri.host, @uri.port)
          @http.use_ssl = true
          @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          if store.gateway == 'MerchantWarehouse'
            @request = Net::HTTP::Post.new(@uri.request_uri, { 'Content-Type' => 'text/xml; charset=utf-8' })
          else
            @request = Net::HTTP::Post.new(@uri.request_uri)
          end
          @request.body = post_parameters

          @response = @http.request(@request)
        
          x = REXML::Document.new Nokogiri.XML(@response.body).to_s
        
          puts x
        
          # Parse Transaction Response
          json_response = parseGatewayResponse(x, store.gateway, cardData['card_last_four'], "#{cardData['expiration_month']}#{cardData['expiration_year']}", amount, 'Void')
        
          # If Void Fails Try Refund
          if ActiveSupport::JSON.decode(json_response)["RespMSG"] != 'Approved' && transaction_type == "Void"
            post_parameters = gatewaySpec(store.gateway, post_url, store.gateway_username, store.gateway_password, store.gateway_storename, 'Return', cardData, params[:orderId], amount, transaction_id, '', '', nil, nil)
            # Get Transaction Response          
            @uri = URI.parse("#{post_url}")
            # Full control
            @http = Net::HTTP.new(@uri.host, @uri.port)
            @http.use_ssl = true
            @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            if store.gateway == 'MerchantWarehouse'
              @request = Net::HTTP::Post.new(@uri.request_uri, { 'Content-Type' => 'text/xml; charset=utf-8' })
            else
              @request = Net::HTTP::Post.new(@uri.request_uri)
            end
            @request.body = post_parameters
            @response = @http.request(@request)
            x = REXML::Document.new Nokogiri.XML(@response.body).to_s
            puts x
            # Parse Transaction Response
            json_response = parseGatewayResponse(x, store.gateway, cardData['card_last_four'], "#{cardData['expiration_month']}#{cardData['expiration_year']}", amount, 'Refund')
          end
          # Respond To App
          respond_to do |format|
            format.json { render :text => json_response }
          end
        
        end
      

        # Gateway Information

      
        def gatewayUrl(gateway, gateway_status)
          
          # Pay Leap Gateway
          if gateway == 'PayLeapGateway'
            if gateway_status == 'live'
              return "https://secure1.payleap.com/TransactServices.svc/ProcessCreditCard?"
            else
              return "https://uat.payleap.com/transactservices.svc/ProcessCreditCard?"
            end
          end
          
          # PROCharge Gateway
          if gateway == 'ProChargeGateway'
            if gateway_status == 'live'
              return "https://secure.procharge.com/isapi/WebAPI.dll?Evendra&"
            else
              return "https://secure.procharge.com/isapi/WebAPI.dll?Evendra&"
            end
          end
          
          # Merchant Wharehouse Gateway
          if gateway == 'MerchantWarehouse'
            return "https://ps1.merchantware.net/Merchantware/ws/RetailTransaction/v4/CreditIDTech.asmx"
          end
          
          # Base Commerce
          
        end

        def gatewaySpec(gateway, post_url, api_username, api_password, api_storename, transaction_type, cardInfo, invoice_number, amount, pnref, zip, street, register_id, origionalMagData)
          # Pay Leap Gateway
          if gateway == 'PayLeapGateway'
            return ("UserName=#{api_username}&Password=#{api_password}&TransType=#{transaction_type}&CardNum=#{cardInfo['card_number']}&ExpDate=#{cardInfo['expiration_month']}#{cardInfo['expiration_year']}&MagData=#{cardInfo['magdata']}&NameOnCard=#{cardInfo['first_name']}#{cardInfo['last_name']}&Amount=#{amount}&InvNum=#{invoice_number}&PNRef=#{pnref}&Zip=#{zip}&Street=#{street}&CVNum=#{cardInfo['cvv']}&ExtData=").to_s.gsub(' ', '%20')
          end
          # PROCharge Gateway
          if gateway == 'ProChargeGateway'
            return ("UserName=#{api_username}&Password=#{api_password}&TransType=#{transaction_type}&CardNum=#{cardInfo['card_number']}&ExpDate=#{cardInfo['expiration_month']}#{cardInfo['expiration_year']}&MagData=#{cardInfo['magdata']}&NameOnCard=#{cardInfo['first_name']}#{cardInfo['last_name']}&Amount=#{amount}&InvNum=#{invoice_number}&PNRef=#{pnref}&Zip=#{zip}&Street=#{street}&CVNum=#{cardInfo['cvv']}&ExtData=").to_s.gsub(' ', '%20')
          end
          # MerchantWarehouse Gateway
          if gateway == 'MerchantWarehouse'
            # Sale
            if transaction_type == 'Sale'
              encryptedTrack = origionalMagData.split('?*')[2]
              soap = "<?xml version='1.0' encoding='utf-8'?>
                      <soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'>
                        <soap12:Body>
                          <#{transaction_type} xmlns='http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/'>
                            <merchantName>#{api_storename}</merchantName>
                            <merchantSiteId>#{api_username}</merchantSiteId>
                            <merchantKey>#{api_password}</merchantKey>
                            <invoiceNumber></invoiceNumber>
                            <amount>#{amount}</amount>
                            <encryptedTrack>#{encryptedTrack[0..-107]}</encryptedTrack>
                            <ksn>#{(origionalMagData[0..-7])[-20..-1]}</ksn>
                            <forceDuplicate>False</forceDuplicate>
                            <registerNumber>#{register_id}</registerNumber>
                            <merchantTransactionId></merchantTransactionId>
                            <entryMode></entryMode>
                          </Sale>
                        </soap12:Body>
                      </soap12:Envelope>"
            end
            # Void Transaction
            if transaction_type == 'Void'
              soap = "<?xml version='1.0' encoding='utf-8'?>
                        <soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'>
                          <soap12:Body>
                            <Void xmlns='http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/'>
                              <merchantName>#{api_storename}</merchantName>
                              <merchantSiteId>#{api_username}</merchantSiteId>
                              <merchantKey>#{api_password}</merchantKey>
                              <token>#{pnref}</token>
                              <registerNumber>#{register_id}</registerNumber>
                              <merchantTransactionId></merchantTransactionId>
                            </Void>
                          </soap12:Body>
                        </soap12:Envelope>"
            end
            if transaction_type == 'Return'
              soap = "<?xml version='1.0' encoding='utf-8'?>
                        <soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'>
                          <soap12:Body>
                            <Refund xmlns='http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/'>
                              <merchantName>#{api_storename}</merchantName>
                              <merchantSiteId>#{api_username}</merchantSiteId>
                              <merchantKey>#{api_password}</merchantKey>
                              <invoiceNumber></invoiceNumber>
                              <token>#{pnref}</token>
                              <overrideAmount>#{amount}</overrideAmount>
                              <registerNumber>#{register_id}</registerNumber>
                              <merchantTransactionId></merchantTransactionId>
                            </Refund>
                          </soap12:Body>
                        </soap12:Envelope>"
            end
            return soap
          end
        end

        def parseGatewayResponse(response, gateway, card_last_four, expiration_date, amount, transaction_type)
          # PayLeap Gateway
          if gateway == 'PayLeapGateway'
            if response.root.elements['RespMSG'].text == 'Approved'
              return '{"RespMSG" : "' + "#{response.root.elements['RespMSG'].text}" + '", "authcode" : "' + "#{response.root.elements['AuthCode'].text}" + '", "transid" : "' + "#{response.root.elements['PNRef'].text}" + '", "card_last_four" : "' + "#{card_last_four}" + '", "exp_date" : "' + "#{expiration_date}" + '", "amount" : "' + "#{amount}" + '"}'
            else
              return '{"RespMSG" : "' + "#{response.root.elements['RespMSG'].text}" +' "}'
            end
          end
          # PROCharge Gateway
          if gateway == 'ProChargeGateway'
            if response.root.elements['RespMSG'].text == 'Approved'
              return '{"RespMSG" : "' + "#{response.root.elements['RespMSG'].text}" + '", "authcode" : "' + "#{response.root.elements['AuthCode'].text}" + '", "transid" : "' + "#{response.root.elements['PNRef'].text}" + '", "card_last_four" : "' + "#{card_last_four}" + '", "exp_date" : "' + "#{expiration_date}" + '", "amount" : "' + "#{amount}" + '"}'
            else
              return '{"RespMSG" : "' + "#{response.root.elements['RespMSG'].text}" +' "}'
            end
          end
          # Merchant Warehouse Gateway
          if gateway == 'MerchantWarehouse'
            # Sale Response
            if transaction_type == 'Sale'
              doc = Nokogiri::XML(response.to_s)
              res = doc.xpath('//res:SaleResult', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/')
              approvalStatus = res.xpath('res:ApprovalStatus', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s
              if approvalStatus == 'APPROVED'
                return '{"RespMSG" : "' + "Approved" + '", "authcode" : "' + "#{res.xpath('res:AuthorizationCode', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s}" + '", "transid" : "' + "#{res.xpath('res:Token', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s}" + '", "card_last_four" : "' + "#{card_last_four}" + '", "exp_date" : "' + "#{expiration_date}" + '", "amount" : "' + "#{amount}" + '"}'
              else
                return '{"RespMSG" : "' + "#{approvalStatus.split(';')[2]}" +' "}'
              end
            end
            # Void Response
            if transaction_type == 'Void'
              doc = Nokogiri::XML(response.to_s)
              res = doc.xpath('//res:VoidResult', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/')
              approvalStatus = res.xpath('res:ApprovalStatus', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s
              if approvalStatus == 'APPROVED'
                return '{"RespMSG" : "' + "Approved" + '", "authcode" : "' + "#{res.xpath('res:AuthorizationCode', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s}" + '", "transid" : "' + "#{res.xpath('res:Token', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s}" + '", "card_last_four" : "' + "#{card_last_four}" + '", "exp_date" : "' + "#{expiration_date}" + '", "amount" : "' + "#{amount}" + '"}'
              else
                return '{"RespMSG" : "' + "#{approvalStatus.split(';')[2]}" +' "}'
              end
            end
            # Refund Response
            if transaction_type == 'Refund'
              doc = Nokogiri::XML(response.to_s)
              res = doc.xpath('//res:RefundResult', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/')
              approvalStatus = res.xpath('res:ApprovalStatus', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s
              if approvalStatus == 'APPROVED'
                return '{"RespMSG" : "' + "Approved" + '", "authcode" : "' + "#{res.xpath('res:AuthorizationCode', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s}" + '", "transid" : "' + "#{res.xpath('res:Token', 'res' => 'http://schemas.merchantwarehouse.com/merchantware/40/CreditIDTech/').inner_text.to_s}" + '", "card_last_four" : "' + "#{card_last_four}" + '", "exp_date" : "' + "#{expiration_date}" + '", "amount" : "' + "#{amount}" + '"}'
              else
                return '{"RespMSG" : "' + "#{approvalStatus.split(';')[2]}" +' "}'
              end
            end
            # end Merchant Wharehouse
          end
          # End Gateays
        end
      
      
        # Credit Card Formatting
      
      
        def format_credit_card(magdata, card_number, exp_date, name, cv2)
          if magdata.blank?
            number = card_number
            first_name = name.split(" ").first
            last_name = name.split(" ").last
            expiration_month = "#{exp_date[0]}#{exp_date[1]}"
            expiration_year = "#{exp_date[2]}#{exp_date[3]}"
            cvv = cv2
          else
            magdata = magdata.to_s.gsub("'","").gsub("  ","")
            track1 = magdata.split(";").first.split("^")
            track2 = magdata.split(";").last
            if !track1.blank?
              number = track1[0].gsub(/\D/, "")
              first_name = track1[1].split("/").last.split(' ').first
              last_name = track1[1].split("/").first
              expiration_month = "#{track1[2][2]}#{track1[2][3]}"
              expiration_year = "#{track1[2][0]}#{track1[2][1]}"
              cvv = nil
            else
              if track2.count("=") != 1 
                error = 'Cannot Read Card'
              end
              data = track2.split('=')
              number = data[0].gsub(/\D/, "")
              first_name = nil
              last_name = nil
              expiration_month = "#{data[1][2]}#{data[1][3]}"
              expiration_year = "#{data[1][0]}#{data[1][1]}"
              cvv = nil
            end
            if error != nil
              return { 'status' => 'error', 'error_msg' => 'Cannot Read Card'}
            end
          end
          return {'status' => 'ok', 'first_name' => first_name, 'last_name' => last_name, 'card_number' => number, 'expiration_month' => expiration_month, 'expiration_year' => expiration_year, 'cvv' => cvv, 'card_last_four' => number[-4..-1], 'magdata' => URI.escape(magdata)}
        end


  #
  # Gift Cards
  #

        def gift_card_payment
          company = Company.first(:api_token => params[:api_token])
          result = GiftCard.chargeCard(company.id, params[:card_number], params[:amount], params[:order_id], params[:store_id])
          if result == false
            respond = '{"status" : "fail"}'
          else
            respond = result
          end
          respond_to do |format|
            format.json { render :json => respond }
          end
        end

        def cancelGiftCardPayment
          # Verify token
          company = Company.first(:api_token => params[:api_token])
          if !company
            return false
          end
          # Refund Gift Card
          gift_card = GiftCard.find(params[:card_id])
          status = 'fail'
          if gift_card
            gift_card.cancelCharge(params[:trans_id])
            status = 'ok'
          end
          respond_to do |format|
            format.json { render :json => '{"status" : "' + status + '"}' }
          end
        end
  
end
