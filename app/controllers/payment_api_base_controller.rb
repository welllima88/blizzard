require 'base_commerce/base_commerce_client.rb'
require 'base_commerce/bank_card_transaction.rb'

class PaymentApiBaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  #
  # Build profile
  #
  
  def build_profile
    # Setup Client
    @@base_client = BaseCommerceClient.new( "evendraposllc1", "A4AfvDFne9f5rZfF5jhq", "545E25C83B202FB61FF298AB4FCBCEFB54B986805E6D83B3" )
    @@base_client.sandbox = true
    
  end
  
  
  #
  # Credit Card Payment
  #
  
  def credit_card_payment
    
    build_profile
    
    # What type of transaction is the manual or swipe?
    if params[:magdata].blank? && !params[:card_number].blank?
      response = manual_credit_card_transaction(params[:name], params[:card_number], params[:exp], params[:cvv], params[:payment_amount])
    else
      mag_data = "02B001001F3A2800%*4833********5718^PERRY/STEFFAN^***********************?*;4833********5718=********************?*BAE6022A84407F381B153F0DD8F6A78D54826ECCE986468F015EC8DA1D770284224A9E1988308D10CD37669CA00F396F0A353AE9EC90D170669308673AEBB27FC6E0C44D7DF606E3BDCFB5A9D0BCFB439A226CE3BA2D339851FF1E8DD36073B498D4BE994C5E491695BE40A24358BDEC4E30E51309EF5844AE7ED5CFB05585867E0C29EFDB988731F8690E9A47272A6D57068CB8108FB816629949143A0002C000A9745803"
      response = swipe_credit_card_transaction(mag_data, params[:payment_amount])
    end
    
    respond_to do |format|
      format.json { render :json => response }
    end
    
  end
  
  def swipe_credit_card_transaction(mag_data, amount)
    o_bct = BankCardTransaction.new
    o_bct.type = BankCardTransaction.xs_bct_type_sale
    o_bct.amount = amount
   #o_bct.card_track1_data = mag_data
   #o_bct.card_track2_data = mag_data
    o_bct.encrypted_track_data = mag_data

    o_bct = @@base_client.process_bank_card_transaction(o_bct)

    if o_bct.status == BankCardTransaction.xs_bct_status_failed
      puts o_bct.messages
      response = { "status" => 0, "msg" => o_bct.messages, "code" => nil }
    elsif o_bct.status == BankCardTransaction.xs_bct_status_declined
      puts o_bct.response_code
      puts o_bct.response_message
      response = { "status" => 0, "msg" => o_bct.response_message, "code" => o_bct.response_code }
    elsif
      response = { "status" => 1, "transaction_id" => o_bct.id, "card_last_four" => o_bct.card_number[-4,4] }
    end
    return response
  end
  
  def manual_credit_card_transaction(name, card_number, exp, cvv, amount)
    o_bct = BankCardTransaction.new
    o_bct.type = BankCardTransaction.xs_bct_type_sale
    o_bct.amount = amount
    o_bct.card_name = name
    o_bct.card_number = card_number
    o_bct.card_expiration_month = "#{exp[0]}#{exp[1]}"
    o_bct.card_expiration_year = "20#{exp[2]}#{exp[3]}"
    o_bct.card_cvv2 = cvv

    o_bct = @@base_client.process_bank_card_transaction(o_bct)

    if o_bct.status == BankCardTransaction.xs_bct_status_failed
      puts o_bct.messages
      response = { "status" => 0, "msg" => o_bct.messages, "code" => nil }
    elsif o_bct.status == BankCardTransaction.xs_bct_status_declined
      puts o_bct.response_code
      puts o_bct.response_message
      response = { "status" => 0, "msg" => o_bct.response_message, "code" => o_bct.response_code }
    elsif
      response = { "status" => 1, "transaction_id" => o_bct.id, "card_last_four" => o_bct.card_number[-4,4] }
    end
    return response
  end
  
  def swipe_credit_card
    # future code here
  end
  
  #
  # Refunds
  #
  
  
  def credit_card_refund
    
    # First lets try to void the sale
      transaction_id = params[:transaction_id]
      void_transaction = params[:void_trans].to_i
      amount =  params[:amount].to_f
      
      if void_transaction != 1
        origional_sale = Order.find(params[:order_id])
        if origional_sale
          origional_payment = origional_sale.order_payments.select{|p| p.transaction_id.to_s == transaction_id.to_s }.first
          if origional_payment && origional_payment.amount == amount
            void_transaction = 1
          end
        end
      end
      
      # Try to void if we can
      if void_transaction == 1
        resp = void_credit_card(transaction_id)
      end
      
      # If the void failed, try a refund
      if !resp || (resp && resp['status'] != 1)
        resp = refund_credit_card(transaction_id, amount)
      end 
      
      respond_to do |format|
        format.json { render :json => resp.to_json }
      end
      
  end
  
  
  def void_credit_card(transaction_id)
    build_profile
    
    o_bct = BankCardTransaction.new
    o_bct.type = BankCardTransaction.xs_bct_type_void
    o_bct.id = transaction_id
    
    o_bct = @@base_client.process_bank_card_transaction(o_bct);

    if o_bct.status == BankCardTransaction.xs_bct_status_failed
      response = {"status" => 0, "msg" => o_bct.messages[0]}
    elsif o_bct.status == BankCardTransaction.xs_bct_status_declined
      response = {"status" => 0, "msg" => o_bct.response_message[0], "code" => o_bct.response_code}
    elsif o_bct.status == BankCardTransaction.xs_bct_status_voided
      puts o_bct.to_json
      response = {"status" => 1, "transaction_id" => o_bct.id, "amount" => o_bct.amount, "authcode" => o_bct.authorization_code, "card_last_four" => o_bct.card_number[-4,4] }
    end
    return response
  end
  
  
  def refund_credit_card(transaction_id, amount)
    build_profile
    
    o_bct = BankCardTransaction.new
    o_bct.type = BankCardTransaction.xs_bct_type_refund
    o_bct.id = transaction_id
    o_bct.amount = amount
    
    o_bct = @@base_client.process_bank_card_transaction(o_bct)

    if o_bct.status == BankCardTransaction.xs_bct_status_failed
      response = {"status" => 0, "msg" => o_bct.messages[0]}
    elsif o_bct.status == BankCardTransaction.xs_bct_status_declined
      response = {"status" => 0, "msg" => o_bct.response_message[0], "code" => o_bct.response_code}
    elsif
      response = {"status" => 1, "transaction_id" => o_bct.id, "amount" => o_bct.amount, "authcode" => o_bct.authorization_code }
    end                              
    return response       
  end
  
  # Used for partial refunds on capture but not settled transactions, last reseort
  def credit_credit_card
    
    build_profile
    
    puts "Card Number : " + params[:card_number].to_s

    o_bct = BankCardTransaction.new
    o_bct.type = BankCardTransaction.xs_bct_type_credit
    o_bct.amount = params[:refund_amount]
    
    # If swiped
    if !params[:card_mag_data].blank?
      # This needs to be completed
    else
      o_bct.card_name = params[:card_name]
      o_bct.card_number = params[:card_number].to_s
      o_bct.card_expiration_month = params[:card_exp_month]
      o_bct.card_expiration_year = params[:card_exp_year]
      o_bct.card_cvv2 = params[:card_cvv]
    end
    
    
    o_bct = @@base_client.process_bank_card_transaction(o_bct)

    if o_bct.status == BankCardTransaction.xs_bct_status_failed
      response = {"status" => 0, "msg" => o_bct.messages[0]}
    elsif o_bct.status == BankCardTransaction.xs_bct_status_declined
     response = {"status" => 0, "msg" => o_bct.response_message[0], "code" => o_bct.response_code}
    elsif
      response = {"status" => 1, "transaction_id" => o_bct.id, "amount" => o_bct.amount, "authcode" => o_bct.authorization_code }
    end    
    
    puts "RESPONSE:" + response.to_s                          
    
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
          
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
        
        
        # Test Swipe: 
  
  
end
