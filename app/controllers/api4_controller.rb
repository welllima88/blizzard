class Api4Controller < ApplicationController
  
  before_filter :get_company_id, :except => [:try_to_login, :dev]
  skip_before_filter :verify_authenticity_token
  
  # Login 
  
  def try_to_login
    user = Employee.authenticate(params[:company_id], params[:username], params[:password])
    if user
      company = Company.find(params[:company_id])
      response = { "status" => 1, "user" => user, "company" => company, "stores" => company.stores, "registers" => company.registers }
    else
      response = { :status => 0 }
    end
    respond_to do |format|
      format.json { render :json => response}
    end
  end
  
  # Products
  
  def load_products
    respond_to do |format|
      format.json { render :json => Product.where( :company_id => Company.find_by_api_token(params[:api_token]).id ).fields(
        :commission_overide,
        :commission_overide_amount,
        :company_id,
        :cost,
        :department_id,
        :desired_level,
        :enable_commission,
        :id,
        :pid,
        :in_transfer,
        :isle,
        :low_stock,
        :manufacturer_id,
        :min_store_level,
        :name,
        :nontax,
        :on_order,
        :price,
        :reorder_level,
        :return_price,
        :sale_price,
        :shelf,
        :status,
        :stock,
        :tags,
        :upc,
        :ean,
        :sku,
        :m_sku
        ) }
    end
  end
  
  def find_customer
    customer = Customer.first(:$or => [{:phone => params[:q].gsub(/\D/, ""), :company_id => @company_id}, {:email => params[:q].downcase, :company_id => @company_id}]) 
    respond_to do |format|
      if customer != nil
        format.json { render :json => {"status" => 1, "customer_name" => customer.full_name, "customer_id" => customer.id.to_s} }
      else
        format.json { render :json => {"status" => 0} }
      end
    end
  end
  
  def add_customer
    customer = Customer.createOrReturnCustomer(@company_id, params[:first_name], params[:last_name], params[:email], params[:phone], params[:address], params[:city], params[:state], params[:zip])
    if customer
      status = {"status" => 1, "customer_name" => customer.full_name.to_s, "customer_id" => customer.id.to_s, "points" => customer.points.to_s }
    else
      status = {"status" => 0}
    end
    respond_to do |format|
      format.json { render :json => status }
    end
  end
  
  def reload_data
    company = Company.find_by_api_token( params[:api_token] )
    response = { "coupons" => company.coupons }
    respond_to do |format|
      format.json { render :json => response }
    end
  end
  
  #
  # Sale
  #
  
  def sync_order
    data = JSON.parse(params[:orderData])
    data['created_at'] = Time.at(data['created_at'].to_i/1000)
    order = Order.new(data)
    order.company_id = @company_id
    order.status = 1
    if order.save
      saved = 1
    else
      saved = 0
    end
    respond_to do |format|
      format.json { render :json => { "status" => saved } }
    end
  end
  
  
  #
  # Returns
  #
  
  def return_get_order
    order = Order.find(params[:order_id])
    if order
      response = { "status" => 1, "order_data" => order.to_json }
    else
      response = { "status" => 0 }
    end
    respond_to do |format|
      format.json { render :json => response }
    end
  end
  
  def sync_return
    data = JSON.parse(params[:returnData])
    puts data
    data['company_id'] = @company_id
    data['created_at'] = Time.at(data['created_at']/1000)
    order_return = OrderReturn.new.from_json( data.to_json )
    if order_return.save
      saved = 1
    else
      saved = 0
    end  
    respond_to do |format|
      format.json { render :json => { "status" => saved } }
    end
  end
  
  
  #
  # Options
  #
  
  def logOffEmployee
    respond_to do |format|
      format.json { render :json => {"status" => Register.find(params[:register_id]).update_attributes(:current_employee_id => nil, :current_employee => nil)} }
    end
  end
  
  def add_cash_to_register

    register = Register.first(:company_id => @company_id, :id => params[:register_id])
    
    if register
      response = register.addToTill(params[:employee_id], params[:employee_name], params[:amount], register.till+params[:amount].to_f, Time.at( params['timestamp'].to_i / 1000.0 ), params[:id])
    else
      response = { "status" => 0 }
    end
    
    respond_to do |format|
      format.json { render :json => response }
    end
    
  end
  
  def remove_cash_from_register
    
    register = Register.first(:company_id => @company_id, :id => params[:register_id])
    
    if register
      response = register.removeFromTill(params[:employee_id], params[:employee_name], params[:amount], register.till-params[:amount].to_f, Time.at( params['timestamp'].to_i / 1000.0 ), params[:id])
    else
      response = { "status" => 0 }
    end
    
    respond_to do |format|
      format.json { render :json =>  response }
    end
    
  end
  
  def submit_till_verification # verifies, opens and closes register 
    
    register = Register.find(params[:register_id])
    
    # Verify Till
    if params[:verificationMethod].to_i == 0
      register.verifyTill( params[:employee_id], params[:employee_name], params[:amount], params[:amount].to_f, Time.at( params['timestamp'].to_i / 1000.0 ), params[:id] )
    end
    
    # Close Register
    if params[:verificationMethod].to_i == 1
      register.closeRegister(params[:employee_id], params[:employee_name], params[:amount], params[:amount].to_f, Time.at( params['timestamp'].to_i / 1000.0 ))
    end
    
    # Open Register
    if params[:verificationMethod].to_i == 2
      register.openRegister(params[:employee_id], params[:employee_name], params[:amount], params[:amount].to_f, Time.at( params['timestamp'].to_i / 1000.0 ))
      #@register.open_register(params[:till_amount].gsub("$", "").to_f, session[:user])
    end
    
    respond_to do |format|
      format.json { render :json =>  '{"status" : "ok", "new_till": "' + (register.till).to_s + '"}'}
    end
    
  end
  
  
  #
  # Timesheets 
  #
  
  def punch_clock
    
    user = Employee.authenticate(@company_id, params[:username], params[:password])
    puts user.to_json;
    if user
      response = { "status" => 1, "employee_name" => user.full_name.titleize, "clock" => Timesheet.punch_clock(params[:store_id], params[:time].to_i/1000.0, user.id) }
    else
      response = { "status" => 0 }
    end
    
    respond_to do |format|
      format.json { render :json => response }
    end
    
  end
  
  
  
  
  #
  # Company Sync Check
  #
  
  def company_sync_check
    get_company_id
    if @company_id != session[:user]['company_id']
      session[:user] = nil
    end
    
  end
  
  # Development
  

  
  def dev
    
    for timesheet in Timesheet.all()
      timesheet.date = timesheet.date.to_i
      timesheet.save
    end
    
    for employee_timesheet in EmployeeTimesheet.all()
      employee_timesheet.date = employee_timesheet.date.to_i
      if employee_timesheet.compensation_type == 'hourly'
        employee_timesheet.compensation_type = 0
      else
        employee_timesheet.compensation_type = 1
      end
      employee_timesheet.save
    end
    
  end
  
  
  # Private Section
  private
  
  def get_company_id
    @company_id = Company.first(:api_token => params[:api_token]).id.to_s
  end
  
  
end
