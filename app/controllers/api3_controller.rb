class Api3Controller < ApplicationController
  before_filter :get_company_id, :except => [:tryToLogin]
  skip_before_filter :verify_authenticity_token
  
  # Login Section (iPad Apps)
  def tryToLogin
    user = Employee.authenticate(params[:company_id], params[:username], params[:password])
    if user
      company = Company.find(params[:company_id])
      response = '{"status" : "ok", "globalCompanyToken" : "' + company.api_token + '", "globalCompanyID" : "' + company.id + '", "globalCompanyName" : "' + company.company_name + '", "globalEmployeeId" : "' + user.id + '", "globalEmployeeName" : "' + user.full_name + '", "globalStores" : ' + Store.all(:company_id => company.id).to_json + ', "globalRegisters" : ' + Register.all(:company_id => company.id).to_json + '}'
    else
      response = '{"status" : "fail"}'
    end
    respond_to do |format|
      format.json { render :json => response}
    end
  end
  
  # Load Products
  
  def loadProducts    
    products = Product.all(:company_id => @company_id)
    if products == nil
      respond = '{"status" : "uptodate"}'
    else
      items = ''
      for p in products
        tags = ("#{p.name} #{p.id} #{p.upc} #{p.sku} #{p.m_sku} #{p.ean}").downcase
        if items == ''
          items += '{"id" : "' + p.id.to_s + '", "product_id" : "' + p.id.to_s + '", "name" : "' + p.name.to_s + '", "upc" : "'+ p.upc.to_s + '", "sku" : "' + p.sku.to_s + '", "ean" : "' + p.ean.to_s + '", "m_sku" : "' + p.m_sku.to_s + '", "price" : "' + p.price.to_s + '", "cost" : "' + p.cost.to_s + '", "nontax" : "' + p.nontax.to_s + '", "return_price" : "' + p.return_price.to_s + '", "tags" : "' + tags.to_s + '"}'
        else
          items += ', {"id" : "' + p.id.to_s + '", "product_id" : "' + p.id.to_s + '", "name" : "' + p.name.to_s + '", "upc" : "'+ p.upc.to_s + '", "sku" : "' + p.sku.to_s + '", "ean" : "' + p.ean.to_s + '", "m_sku" : "' + p.m_sku.to_s + '", "price" : "' + p.price.to_s + '", "cost" : "' + p.cost.to_s + '", "nontax" : "' + p.nontax.to_s + '", "return_price" : "' + p.return_price.to_s + '", "tags" : "' + tags + '"}'
        end
      end
      respond = '{"status" : "reload", "items" : ['+ items +']}'
    end
    respond_to do |format|
      format.json { render :json => respond }
    end
  end
  
  # Load Coupons
  
  def getCouponsFromServer
    respond_to do |format|
      format.json { render :json => Coupon.all(:company_id => @company_id, :start_date.lte => Time.now, :end_date.gte => Time.now).to_json }
    end
  end
  
  # Sync Order
  
  Time.zone = "EST"
  
  def sync_order
    if !@company_id
      return false
    end
    data = JSON.parse(params[:orderData])
    order = Order.new(data)
    order.status = 'complete'
    order.company_id = @company_id
    order.created_at = Time.parse("#{data['created_at']}")
    order.status = 1
    if order.save
      saved = 'yes'
    else
      saved = 'no'
    end
    respond_to do |format|
      format.json { render :json => saved }
    end
  end
  
  
  # Customers
  
  def findCustomer
    customer = Customer.first(:$or => [{:phone => params[:q].gsub(/\D/, ""), :company_id => @company_id}, {:email => params[:q].downcase, :company_id => @company_id}]) 
    respond_to do |format|
      if customer != nil
        format.json { render :json => '{"status" : "success", "customer_name" : "' + customer.full_name + '", "customer_id" : "' + customer.id.to_s + '"}' }
      else
        format.json { render :json => '{"status" : "fail", "customer_name" : "' + params[:api_token] + '", "customer_id" : ""}' }
      end
    end
  end
  
  def addCustomer
    customer = Customer.createOrReturnCustomer(@company_id, params[:first_name], params[:last_name], params[:email], params[:phone], params[:address], params[:city], params[:state], params[:zip])
    if customer != nil
      status = 'success'
    else
      status = 'error'
    end
    respond_to do |format|
      format.json { render :json => '{"status": "' + status + '", "customer_name" : "' + customer.full_name.to_s + '", "customer_id" : "' + customer.id.to_s + '", "points" : "' + customer.points.to_s + '"}' }
    end
  end
  
  #
  # Returns 
  #
  
  def returnGetOrder
    puts Order.find(params[:order_id]).to_json
    respond_to do |format|
      format.json { render :json => Order.find(params[:order_id]).to_json }
    end
  end
  
  def sync_return
    if !@company_id
      return false
    end
    data = JSON.parse(params[:returnData])
    order_return = OrderReturn.new(data)
    order_return.status = 'complete'
    order_return.company_id = @company_id
    order_return.created_at = Time.parse("#{data['created_at']}")
    order_return.status = 'complete'
    if order_return.save
      saved = 'success'
    else
      saved = 'fail'
    end
    respond_to do |format|
      format.json { render :json => '{"status" : "' + saved + '"}' }
    end
  end
  
  #
  # Timesheets
  #
  
  def punchClock
    logged_in_user = Employee.authenticate(@company_id, params[:username], params[:password])
    if logged_in_user == nil
      respond = '{"status" : "fail"}'
    else
      respond = '{"status" : "success", "employee_name" : "' + logged_in_user.full_name.titleize + '", "clock" : "' + Timesheet.punchClock(params[:store_id], params[:time], logged_in_user.id) + '"}'
    end
    respond_to do |format|
      format.json { render :json => respond }
    end
  end
  
  def syncOfflineTimeCards
    timecards = JSON.parse(params[:timecards]).sort! { |x,y| x[:time] <=> y[:time] }
    errors = []
    for t in timecards
      logged_in_user = Employee.where(:company_id => @company_id, :username => t['username']).first
      if logged_in_user != nil
        if Timesheet.punchClock(params[:store_id], t['time'], logged_in_user.id) == false
          errors << t
        end
      else
        errors << t
      end
    end
    respond_to do |format|
      format.json { render :json => errors }
    end
  end
  
  #
  # Till Additions/Subtrations
  #
  
  def addCashToRegister
    register = Register.first(:company_id => @company_id, :id => params[:register_id])
    register.addToTill(params[:employee_id], params[:employee_name], params[:amount], register.till+params[:amount].to_f, Time.parse("#{params['timestamp']}"))
    respond_to do |format|
      format.json { render :json =>  '{"status" : "ok", "new_till": "' + (register.till).to_s + '"}'}
    end
  end
  
  def removeCashFromRegister
    register = Register.find(params[:register_id])
    register.removeFromTill(params[:employee_id], params[:employee_name], params[:amount], register.till-params[:amount].to_f, Time.parse("#{params['timestamp']}"))
    respond_to do |format|
      format.json { render :json =>  '{"status" : "ok", "new_till": "' + (register.till).to_s + '"}'}
    end
  end
  
  def submitTillVerification # verifies and closes register 
    register = Register.find(params[:register_id])
    # Verify Till
    if params[:verificationMethod].to_i == 0
      register.verifyTill(params[:employee_id], params[:employee_name], params[:amount], params[:amount].to_f, Time.parse("#{params['timestamp']}"))
    end
    # Close Register
    if params[:verificationMethod].to_i == 1
      register.closeRegister(params[:employee_id], params[:employee_name], params[:amount], params[:amount].to_f, Time.parse("#{params['timestamp']}"))
    end
    # Open Register
    if params[:verificationMethod].to_i == 2
      register.openRegister(params[:employee_id], params[:employee_name], params[:amount], params[:amount].to_f, Time.parse("#{params['timestamp']}"))
      #@register.open_register(params[:till_amount].gsub("$", "").to_f, session[:user])
    end
    respond_to do |format|
      format.json { render :json =>  '{"status" : "ok", "new_till": "' + (register.till).to_s + '"}'}
    end
  end
  
  def logOffEmployee
    respond_to do |format|
      format.json { render :json =>  '{"status" : "' + Register.find(params[:register_id]).update_attributes(:current_employee_id => nil, :current_employee => nil) + '"'}
    end
  end
  
  def logInEmployee
    respond_to do |format|
      format.json { render :json =>  '{"status" : "' + Register.find(params[:register_id]).update_attributes(:current_employee_id => params[:employee_id], :current_employee => Employee.find(params[:employee_id]).full_name) + '"'}
    end
  end
  
  def refreshRegisterList
    json = '{"status" : "ok", "globalRegisters": "' + Register.all(:company_id => @company_id).to_json + '"'
    puts json
    respond_to do |format|
      format.json { render :json =>  json}
    end
  end
  
  # Private Section
  private
  
  def get_company_id
    @company_id = Company.first(:api_token => params[:api_token]).id
  end
end
