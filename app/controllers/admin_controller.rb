class AdminController < ApplicationController
  include AdminHelper
  before_filter :check_status
  
  def index
    showSection('Dashboard', '')
    @chart_sales = Order.where(:company_id => session[:user]['company_id'], :created_at.gte => Time.now-6.days).fields(:created_at, :net_profit, :total, :subtotal)
  end
  
#
# Sales Section
#
  
  def sales
    checkAdminAccess('sales')
    showSection('Sales', 'Sales')
    eval("@sales = Order.paginate(:company_id => session[:user]['company_id'], :page => params[:page], :per_page => 20, :order => 'created_at DESC', #{ params[:conditions]})")
  end
  
  def sale
    checkAdminAccess('sales')
    showSection('Sales', '')
    @sale = Order.find(params[:id])
  end
  
  def returns
    checkAdminAccess('sales')
    showSection('Sales', 'Returns')
    @returns = OrderReturn.paginate(:company_id => session[:user]['company_id'], :page => params[:page], :per_page => 20, :order => 'created_at DESC')
  end
  
  def return
    checkAdminAccess('sales')
    showSection('Sales', '')
    @return = OrderReturn.find(params[:id])
  end
  
#
# Inventory Section
#
 
  def inventory
    
    checkAdminAccess('inventory')
    showSection('Inventory', 'Inventory')
    
    sort = 'name'
    if !params[:sort].blank?
      sort = params[:sort]
    end
    
    direction = 'ASC'
    if !params[:direction].blank?
      direction = params[:direction]
    end
    
    active = 1
    if !params[:de_active].blank?
      active = 0
    end
    
    if !params[:search].blank?
      @products = Product.paginate(:$or => [{:name => /#{params[:search]}/i}, {:id => /#{params[:search]}/i}, :upc => /#{params[:search].downcase}/i, :ean => /#{params[:search].downcase}/i, :sku => /#{params[:search].downcase}/i, :m_sku => /#{params[:search].downcase}/i], :company_id => session[:user]['company_id'], :page => params[:page], :per_page => 20, :order => "#{sort} #{direction}")
    else
      @products = Product.paginate(:company_id => session[:user]['company_id'], :status => active, :page => params[:page], :per_page => 20, :order => "#{sort} #{direction}")
    end
    
  end
  
  def add_product
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @company = Company.find(session[:user]['company_id'])
    if params[:product] != nil
      # Create New Products 
      product = Product.new(params[:product])
      product.status = 1
      product.company_id = session[:user]['company_id']
      product.return_price = product.price
      
      # Make sure product has unique identifier codes
      unique_ids = Product.verify_unique(session[:user]['company_id'], params[:product][:upc], params[:product][:ean], params[:product][:sku], params[:product][:m_sku], '')
      if unique_ids == true
        
        # Add inventory Stock
        for s in Store.all(:company_id => session[:user]['company_id'])
          product_inventory = product.product_inventorys.select{|i| i.store_id.to_s == s.id.to_s}.first
          if product_inventory != nil
            product_inventory.qty = params[s.id.to_sym][:qty].to_i
          else
            product.product_inventorys << ProductInventory.new(:store_id => s.id, :qty => params[s.id.to_sym][:qty].to_i)
          end
        end
        
        product.save
        
        
        if product.department_id != nil && product.department_id != ''
          product.set(:department_name => Department.find(@product.department_id).name)
        end
        return redirect_to(:action => 'inventory')
        
      else
        flash[:error] = unique_ids
        return redirect_to(:action => 'add_product')
      end
    end
  end
  
  def product
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @p = Product.find(params[:id])
    @po = Purchaseorder.paginate(:status.in => [0, 1, 2, 3], 'po_items.product_id' => @p.id, :page => params[:popage], :per_page => 5, :order => :created_at.desc)
    @orders = Order.paginate(:status => 1, 'order_line_items.product_id' => @p.id, :page => params[:page], :per_page => 5, :order => :created_at.desc)
    @st = StockTransfer.all('stock_transfer_products.product_id' => @p.id, :status => 'sent')
  end
  
  def edit_product
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @company = Company.find(session[:user]['company_id'])
    @product = Product.find(params[:id])
    if params[:product]
      if @product.upc.to_s != params[:product][:upc].to_s || @product.ean.to_s != params[:product][:ean].to_s || @product.sku.to_s != params[:product][:sku].to_s || @product.m_sku.to_s != params[:product][:m_sku].to_s
        if Product.verify_unique(session[:user]['company_id'], params[:product][:upc], params[:product][:ean], params[:product][:sku], params[:product][:m_sku], @product.id) != true
          flash[:error] = Product.verify_unique(session[:user]['company_id'], params[:product][:upc], params[:product][:ean], params[:product][:sku], params[:product][:m_sku], @product.id)
          return redirect_to(:action => 'edit_product')
        end
      end
      for s in Store.all(:company_id => session[:user]['company_id'])
        product_inventory = @product.product_inventorys.select{|i| i.store_id.to_s == s.id.to_s}.first
        if product_inventory != nil
          product_inventory.qty = params[s.id.to_sym][:qty].to_i
        else
          @product.product_inventorys << ProductInventory.new(:store_id => s.id, :qty => params[s.id.to_sym][:qty].to_i)
        end
      end
      @product.update_attributes(params[:product])
      @product.set_return_price(@product.price)
      redirect_to(:action => 'product', :id => params[:id])
    end
  end
  
  def de_activate_inventory
    Product.set(params[:id], :status => 0)
    redirect_to(:action => 'product', :id => params[:id])
  end
  
  def activate_inventory
    Product.set(params[:id], :status => 1)
    redirect_to(:action => 'product', :id => params[:id])
  end
    
#
# Purchase Orders
#
  
  def purchase_orders
    checkAdminAccess('inventory')
    showSection('Inventory', 'PurchaseOrders')
    if params[:completed] == 'yes'
      @completed = Purchaseorder.all(:company_id => session[:user]['company_id'], :status => 3)
    else
      @pending = Purchaseorder.all(:company_id => session[:user]['company_id'], :status => 0)
      @submitted = Purchaseorder.all(:company_id => session[:user]['company_id'], :status => 1)
      @receiving = Purchaseorder.all(:company_id => session[:user]['company_id'], :status => 2)
    end
  end
  
  def purchase_order
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @po = Purchaseorder.find(params[:id])
  end
  
  def create_po
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @vendors = Vendor.all(:company_id => session[:user]['company_id'])
    if params[:vendor] != nil
      employee = Employee.find(session[:user]['employee_id'])
      vendor = Vendor.find(params[:vendor][:id])
      po = Purchaseorder.first(:vendor_id => vendor.id, :status => 0)
      if po == nil
        po = Purchaseorder.create!(
        :vendor_id => vendor.id,
        :vendor_name => vendor.name,
        :vendor_account_number => vendor.account_number,
        :status => 0,
        :cost => 0,
        :shipping_cost => 0,
        :discount_amount => 0,
        :discount_percent => 0,
        :total => 0,
        :amount_paid => 0,
        :created_at => Time.now,
        :employee_id => employee.id,
        :employee_name => employee.full_name,
        :company_id => session[:user]['company_id']
        )
      end
      redirect_to(:action => 'edit_purchase_order', :id => po.id)
    end
  end
  
  def edit_purchase_order
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @purchaseorder = Purchaseorder.find(params[:id])
    if params[:purchaseorder] != nil
      for p in params
        if p.first.to_i > 0
         i = @purchaseorder.po_items.find(params["#{p.first.to_sym}"][:id])
         Product.increment(i.product_id, :on_order => (params["#{p.first.to_sym}"][:qty].to_i-i.qty.to_i))
         i.qty = params["#{p.first.to_sym}"][:qty]
         @purchaseorder.save
        end
      end
      if params[:item][:id] != ''     
        @purchaseorder.add_to_po(params[:item][:id], params[:item][:qty])
      end
      @purchaseorder.po_items.delete_if{|i| i.qty == 0}
      @purchaseorder.update_attributes(params[:purchaseorder])
      if params[:commit] == 'Done'
        redirect_to(:action => 'purchase_order', :id => params[:id])
      end
    end
  end
  
  def add_low_stock
    checkAdminAccess('inventory')
    purchase_order = Purchaseorder.find(params[:id])
    products = Product.all(:company_id => session[:user]['company_id'], :vendor_id => purchase_order.vendor_id, :low_stock => 1, :sku.ne => 'giftcard')
    for p in products
      purchase_order.add_to_po(p.id, p.adaquate_level)
    end
    redirect_to(:action => 'edit_purchase_order', :id => params[:id])
  end
  
  
  def low_inventory
    checkAdminAccess('inventory')
    showSection('Inventory', 'LowInventory')
    @products = Product.all(:company_id => session[:user]['company_id'], :low_stock => 1, :order => :vendor_id.desc, :sku.ne => 'giftcard')
  end
  
  
  def low_stock_create
    for p in params[:item]
      if p.last.to_i > 0
        product = Product.find(p.first)
        if !product.vendor_id.blank?
          purchase_order = Purchaseorder.first(:company_id => session[:user]['company_id'], :vendor_id => product.vendor_id, :status => 0)
          if purchase_order == nil
            purchase_order = Purchaseorder.create!(:company_id => session[:user]['company_id'], :vendor_id => product.vendor_id, :vendor_name => product.vendor.name, :vendor_account_number => product.vendor.account_number, :status => 0)
          end
          purchase_order.add_to_po(product.id, p.last.to_i)
        end
      end
    end
    redirect_to(:action => 'purchase_orders')
  end
  
  def cancel_po
    checkAdminAccess('inventory')
    po = Purchaseorder.first(:id => params[:id], :company_id => session[:user]['company_id'])
    if po.status.to_s != '0'
      for i in po.po_items
        product = Product.find(i.product_id)
        product.on_order -= i.qty.to_i
        product.save
      end
    end
    po.destroy
    redirect_to(:action => 'purchase_orders')
  end
  
  def receive_purchase_order
    checkAdminAccess('inventory')
    @po = Purchaseorder.find(params[:id])
    @stores = Store.all(:company_id => session[:user]['company_id'])
    if params[:item] != nil
      if @po.status == '1'
        @po.status = '2'
      end
      for p in params[:item]
        if p.last != nil
          po_item = @po.po_items.find(p.first)
          po_item.received += p.last.to_i
          @po.save
          product = Product.find(po_item.product_id)
          product.on_order-= p.last.to_i
          sp = product.product_inventorys.select{|i| i.store_id.to_s == params[:store][:id]}
          sp.first.qty += p.last.to_i
          product.save
        end
      end
    end
  end
  
  def submit_po_to_vendor
    checkAdminAccess('inventory')
    employee = Employee.find(session[:user]['employee_id'])
    emailed = Purchaseorder.submit_to_vendor(params[:id], employee.full_name, session[:user]['company_id'], employee.email)
    redirect_to(:action => 'purchase_orders')
  end
  
  def record_po_payment
    checkAdminAccess('inventory')
    redirect_to(:action => "purchase_order", :id => Purchaseorder.find(params[:id]).add_payment(params[:payment][:payment_type], params[:payment][:amount], params[:payment][:transaction_id]))
  end
  
  def pdf_print_view
    checkAdminAccess('inventory')
    @po = Purchaseorder.find(params[:id])
    @company = Company.find(session[:user]['company_id'])
    @vendor = Vendor.find(@po.vendor_id)
    @po.renderedPdf(@company.id, @vendor.id)
  end
  
  
  
  
  
  
  
  
  
  
  
  #
  # Stock Transfers
  #
  
  def stock_transfers
    checkAdminAccess('inventory')
    showSection('Inventory', 'StockTransfers')
    if params[:completed] == 'yes'
      return @completed = StockTransfer.paginate(:company_id => session[:user]['company_id'], :status => 'complete', :page => params[:complete_page], :per_page => 20)
    end
    @pending = StockTransfer.paginate(:company_id => session[:user]['company_id'], :status => 'pending', :page => params[:pending_page], :per_page => 20)
    @submitted = StockTransfer.paginate(:company_id => session[:user]['company_id'],:status => 'submitted', :page => params[:submitted_page], :per_page => 20)
    @sent = StockTransfer.paginate(:company_id => session[:user]['company_id'],:status => 'sent', :page => params[:sent_page], :per_page => 20)
  end
  
  def stock_transfer
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @stock_transfer = StockTransfer.find(params[:id])
  end
  
  def create_stock_transfer
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @stores = Store.all(:company_id => session[:user]['company_id'])
    if params[:id] != nil
      @stock_transfer = StockTransfer.find(params[:id])
      @source = Store.find(@stock_transfer.source_id)
      @destination = Store.find(@stock_transfer.destination_id)
      products = Product.all(:company_id => session[:user]['company_id'])
      @products = []
      if params[:stock_transfer] == nil
        for p in products
          stock = p.product_inventorys.select{|sp| sp.store_id.to_s == @source.id.to_s}.first
          if stock != nil
            if stock.qty >= 1
              store_product = [p.name, p.id, stock.qty, p.sku]
              @products << store_product
            end
          end
        end
      end
    end
    if params[:stock_transfer] != nil
      if params[:id] == nil
        stock_transfer = StockTransfer.new(params[:stock_transfer])
        stock_transfer.company_id = session[:user]['company_id']
        stock_transfer.created_at = Time.now
        stock_transfer.employee_id = session[:user]['employee_id']
        stock_transfer.employee_name = session[:user]['employee_name']
        stock_transfer.item_count = 0
        stock_transfer.source_name = Store.find(params[:stock_transfer][:source_id]).name
        stock_transfer.destination_name = Store.find(params[:stock_transfer][:destination_id]).name
        stock_transfer.status = 'pending'
        stock_transfer.save
        redirect_to(:action => 'create_stock_transfer', :id => stock_transfer.id)
      else
        stock_transfer = StockTransfer.find(params[:id])
        stock_transfer_qty = 0
        for p in params
          if p[1]['qty'] != nil
            if p[1]['qty'].length >= 1
              if p[1]['qty'].to_i > p[1]['available'].to_i
                p[1]['qty'] = p[1]['available']
              end
              existing = stock_transfer.stock_transfer_products.select{|tp| tp.product_id.to_s == p[1]['id'].to_s}.first
              if existing == nil
                stock_transfer_product = StockTransferProduct.new(:product_id => p[1]['id'], :product_name => p[1]['name'], :qty => p[1]['qty'])
                stock_transfer.stock_transfer_products << stock_transfer_product
              else
                existing.qty = p[1]['qty']
              end
              stock_transfer_qty += p[1]['qty'].to_i
            end
          end
        end
        stock_transfer.item_count = stock_transfer_qty
        stock_transfer.save
        if params[:commit] == 'Submit Transfer'
          stock_transfer.status = 'submitted'
          stock_transfer.save
          redirect_to(:action => 'stock_transfers', :id => stock_transfer.id)
        else
          redirect_to(:action => 'create_stock_transfer', :id => stock_transfer.id)
        end
      end
    end
  end
  
  def send_stock_transfer
    checkAdminAccess('inventory')
    stock_transfer = StockTransfer.find(params[:id])
    if stock_transfer.status != 'sent'
      if stock_transfer.send_stock_transfer == 'success'
        stock_transfer.update_attributes(:status => 'sent', :fulfill_by => session[:user]['employee_name'], :fulfill_by_id => session[:user]['employee_id'])
      end
    end
    redirect_to(:action => 'stock_transfers')
  end
  
  def receive_stock_transfer
    checkAdminAccess('inventory')
    stock_transfer = StockTransfer.find(params[:id])
    if stock_transfer.status == 'sent'
      if stock_transfer.receive_stock_transfer == 'success'
        stock_transfer.update_attributes(:status => 'complete')
      end
    end
    redirect_to(:action => 'stock_transfers')
  end
  
  def cancel_stock_transfer
    checkAdminAccess('inventory')
    stock_transfer = StockTransfer.find(params[:id])
    if stock_transfer.status != 'complete'
      stock_transfer.cancel_stock_transfer
    end
    redirect_to(:action => 'stock_transfers')
  end
  
  






  #
  # Departments
  #
  
  def departments
    checkAdminAccess('inventory')
    showSection('Inventory', 'Departments')
    @departments = Department.paginate(:department_id => nil, :page => params[:page], :per_page => 20, :company_id => session[:user]['company_id'])
  end
  
  def add_department
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    if params[:department] != nil
      department = Department.new(params[:department])
      department.company_id = session[:user]['company_id']
      department.save
      if !params[:department][:department_id].blank?
        #parent_department = Department.push(params[:department][:department_id], :sub_departments => [params[:department][:name].to_s.capitalize, department.id])
      end
      redirect_to(:action => 'departments')
    end
  end
  
  def edit_department
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @department = Department.first(:id => params[:id], :company_id => session[:user]['company_id'])
    if params[:department] != nil
      @department.update_attributes(params[:department])
      redirect_to(:action => 'departments')
    end
  end
  
  def destroy_department
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    Department.first(:id => params[:id], :company_id => session[:user]['company_id']).destroy
    redirect_to(:action => 'departments')
  end
  
  def decrement_department_item_count(id)
    if id != "" && id != nil
      department = Department.find(id)
      department.number_of_items=department.number_of_items-1
      department.save
      if department.department_id != nil
        decrement_department_item_count(department.department_id)
      else
        return true
      end
    else
      true
    end
  end
  
  def increment_department_item_count(id)
    department = Department.find(id)
    department.number_of_items=department.number_of_items+1
    department.save
    if department.department_id != nil
      increment_department_item_count(department.department_id)
    else
      return true
    end
  end









  #
  # manufacturers
  #
  
  def manufacturers
    checkAdminAccess('inventory')
    showSection('Inventory', 'Manufacturers')
    @m = Manufacturer.all(:company_id => session[:user]['company_id'], :order => 'name ASC')
  end
  
  def manufacturer
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @m = Manufacturer.find(params[:id])
  end
  
  def add_manufacturer
    checkAdminAccess('inventory')
    if params[:manufacturer] != nil
      m = Manufacturer.new(params[:manufacturer])
      m.website = params[:manufacturer][:website].gsub("http://","").gsub("https://","")
      m.company_id = session[:user]['company_id']
      m.save
      redirect_to(:action => 'manufacturers')
    end
  end
  
  def edit_manufacturer
    checkAdminAccess('inventory')
    @manufacturer = Manufacturer.find(params[:id])
    if params[:manufacturer] != nil
      @manufacturer.name
      @manufacturer.website = params[:manufacturer][:website].gsub("http://", "").gsub("https://", "")
      @manufacturer.phone = params[:manufacturer][:phone]
      @manufacturer.update_attributes(params[:manufacturer])
      redirect_to(:action => 'manufacturer', :id => params[:id])
    end
  end
  
  def destroy_manufacturer
    checkAdminAccess('inventory')
    if params[:confirm] == 'true'
      @m = Manufacturer.where(:id => params[:id]).first
      for p in @m.products
        p.manufacturer_id = nil
        p.update_attributes(params[:product])
      end
      @m.destroy
      redirect_to(:action => 'manufacturers')
    end
  end





  


  #
  # Vendors
  # 
  
  def vendors
    checkAdminAccess('inventory')
    showSection('Inventory', 'Vendors')
    @vendors = Vendor.all(:company_id => session[:user]['company_id'])
  end
  
  def add_vendor
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @vendors = Vendor.all(:company_id => session[:user]['company_id'])
    if params[:vendor] != nil
      Vendor.create!(params[:vendor])
      redirect_to(:action => 'vendors')
    end
  end
  
  def vendor
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @vendor = Vendor.first(:id => params[:id], :company_id => session[:user]['company_id'])
  end
  
  def edit_vendor
    checkAdminAccess('inventory')
    showSection('Inventory', '')
    @vendor = Vendor.first(:id => params[:id], :company_id => session[:user]['company_id'])
    if params[:vendor] != nil
      @vendor.update_attributes(params[:vendor])
      redirect_to(:action => 'vendors')
    end
  end
  
  
  
  
  
  
  
  
  
  #
  # Customers
  #

  def customers
    checkAdminAccess('customers')
    showSection('Customers', 'Customers')
    @customers = Customer.paginate(:company_id => session[:user]['company_id'], :page => params[:page], :per_page => 25)
  end
  
  def customer
    checkAdminAccess('customers')
    showSection('Customers', '')
    @customer = Customer.find(params[:id])
    @orders = Order.paginate(:company_id => session[:user]['company_id'], :customer_id => @customer.id.to_s, :per_page => 10, :page => params[:page])
  end
  
  def edit_customer
    checkAdminAccess('customers')
    @customer = Customer.find(params[:id])
    if params[:customer] != nil
      @customer.update_attributes(params[:customer])
      redirect_to(:action => 'customer', :id => @customer.id)
    end
  end
  
  
  
  
  
  
  
  
  
  #
  # Employees
  #
  
  def employees
    checkAdminAccess('employees')
    showSection('Employees', 'Employees')
    @employees = Employee.paginate(:company_id => session[:user]['company_id'], :per_page => 20, :page => params[:page])
    @employeecount = Employee.count(:company_id => session[:user]['company_id'])
  end
  
  def employee
    checkAdminAccess('employees')
    showSection('Employees', '')
    @employee = Employee.find(params[:id])
    @employee_timesheets = EmployeeTimesheet.paginate(:employee_id => @employee.id, :page => params[:timesheetPage], :per_page => 6)
  end
  
  def add_employee
    checkAdminAccess('employees')
    showSection('Employees', '')
    if params[:employee] != nil
      @employee = Employee.new(params[:employee])
      @employee.start_date = ("#{params[:employee_start]['date(1i)']}-#{params[:employee_start]['date(2i)']}-#{params[:employee_start]['date(3i)']}").to_time
      @employee.dob = ("#{params[:employee_dob]['date(1i)']}-#{params[:employee_dob]['date(2i)']}-#{params[:employee_dob]['date(3i)']}").to_time
      @employee.compensation = params[:employee_rate][:amount].to_s.gsub("$", "").to_f
      # Roles
      @employee.sales = params[:sales]
      @employee.inventory = params[:inventory]
      @employee.customers = params[:customers]
      @employee.giftcards = params[:giftcards]
      @employee.employees = params[:employees]
      @employee.stores = params[:stores]
      @employee.marketing = params[:marketing]
      @employee.returns = params[:returns]
      # End Roles
      @employee.company_id = session[:user]['company_id']
      @employee.save
      redirect_to(:action => 'employee', :id => @employee.id)
    end
  end
  
  def edit_employee
    checkAdminAccess('employees')
    showSection('Employees', '')
    @employee = Employee.find(params[:id])
    if params[:employee] != nil
      @employee.start_date = ("#{params[:employee_start]['date(1i)']}-#{params[:employee_start]['date(2i)']}-#{params[:employee_start]['date(3i)']}").to_time
      @employee.dob = ("#{params[:employee_dob]['date(1i)']}-#{params[:employee_dob]['date(2i)']}-#{params[:employee_dob]['date(3i)']}").to_time
      @employee.compensation = params[:employee_rate][:amount].to_s.gsub("$", "").to_f
      # Roles
      if Employee.all(:company_id => session[:user]['company_id'], :super_admin => true).count >= 2
        @employee.super_admin = params[:super_admin]
      else
        @employee.super_admin = true
      end
      @employee.sales = params[:sales]
      @employee.inventory = params[:inventory]
      @employee.customers = params[:customers]
      @employee.giftcards = params[:giftcards]
      @employee.employees = params[:employees]
      @employee.stores = params[:stores]
      @employee.marketing = params[:marketing]
      @employee.returns = params[:returns]
      # End Roles
      @employee.update_attributes(params[:employee])
      setAdminSession
      redirect_to(:action => 'employee', :id => @employee.id)
    end
  end
  

  
  
  
  
  
  
  
  #
  # Timesheets
  #
  
  def timesheets
    checkAdminAccess('employees')
    showSection('Employees', 'Timesheets')
    @timesheets = Timesheet.paginate(:company_id => session[:user]['company_id'], :page => params[:page], :per_page => 20, :order => 'date DESC')
  end
  
  def timesheet
    checkAdminAccess('employees')
    showSection('Employees', '')
    @timesheet = Timesheet.find(params[:id])
  end
  
  def employee_timesheet
    checkAdminAccess('employees')
    showSection('Employees', '')
    @employee_timesheet = EmployeeTimesheet.find(params[:id])
    @timezone = Store.find(@employee_timesheet.store_id).time_zone
  end
  
  def edit_employee_timesheet
    
    # Access
    checkAdminAccess('employees')
    showSection('Employees', '')
    
    # Find the timesheet
    @employee_timesheet = EmployeeTimesheet.find(params[:id])
    
    # Set Timezone
    @timezone = Store.find(@employee_timesheet.store_id).time_zone
    Time.zone="#{@timezone}"
    
    # If we have submitted the form, update the timesheet
    if params[:update] == 'true'
      for hit in @employee_timesheet.employee_timesheet_hits
        hit.clock_in = Time.zone.parse("#{params[hit.id.to_s.to_sym]['clock_in_date(1i)']}-#{params[hit.id.to_s.to_sym]['clock_in_date(2i)']}-#{params[hit.id.to_s.to_sym]['clock_in_date(3i)']} #{hourTo24(params[hit.id.to_s.to_sym][:clock_in_hour], params[hit.id.to_s.to_sym][:in_ampm])}:#{params[hit.id.to_s.to_sym][:clock_in_minute]}")
        hit.clock_out = Time.zone.parse("#{params[hit.id.to_s.to_sym]['clock_out_date(1i)']}-#{params[hit.id.to_s.to_sym]['clock_out_date(2i)']}-#{params[hit.id.to_s.to_sym]['clock_out_date(3i)']} #{hourTo24(params[hit.id.to_s.to_sym][:clock_out_hour], params[hit.id.to_s.to_sym][:out_ampm])}:#{params[hit.id.to_s.to_sym][:clock_out_minute]}")
        hit.total_hours
      end
      @employee_timesheet.save
      flash[:notice] = "Timesheet Updated Successfully"
      redirect_to(:action => 'employee_timesheet', :id => params[:id])
    end

  end








  #
  # Stores
  #
  
  def stores
    checkAdminAccess('stores')
    showSection('Stores', 'Stores')
    @stores = Store.paginate(:company_id => session[:user]['company_id'], :page => params[:page], :per_page => 15)
  end
  
  def store
    checkAdminAccess('stores')
    showSection('Stores', '')
    @store = Store.first(:id => params[:id], :company_id => session[:user]['company_id'])
    Time.zone = @store.time_zone
    @sales = Order.paginate(:store_id => @store.id, :page => params[:page], :per_page => 10, :order => 'created_at DESC')
    @registers = Register.paginate(:store_id => @store.id, :page => params[:pageregister], :per_page => 8)
    @chart_sales = Order.where(:company_id => session[:user]['company_id'], :store_id => @store.id, :created_at.gte => Time.now-6.days).fields(:created_at, :net_profit, :total, :subtotal)
  end
  
  def add_store
    checkAdminAccess('stores')
    showSection('Stores', 'AddStore')
    if params[:store] != nil
      redirect_to(:action => 'store', :id => Store.create!(params[:store]).id)
    end
  end
  
  def edit_store
    checkAdminAccess('stores')
    showSection('Stores', '')
    @store = Store.first(:id => params[:id], :company_id => session[:user]['company_id'])
    if params[:store] != nil
      @store.update_attributes(params[:store])
      redirect_to(:action => 'store', :id => @store.id)
    end
  end
  
  def inventory_locations
    checkAdminAccess('stores')
    showSection('Stores', 'InventoryLocations')
    if params[:store_id] != nil
      @inventory_locations = InventoryLocation.paginate(:company_id => session[:user]['company_id'], :store_id => params[:store_id], :page => params[:page], :per_page => 20)
    else
      @stores = Store.all(:company_id => session[:user]['company_id'])
    end
  end
  
  def addInventoryLocation
    checkAdminAccess('stores')
    @stores = Store.all(:company_id => session[:user]['company_id'])
    if params[:inventory_location] != nil
      inventorylocation = InventoryLocation.new(params[:inventory_location])
      inventorylocation.company_id = session[:user]['company_id']
      inventorylocation.save
      redirect_to(:action => 'inventory_locations', :store_id => params[:inventory_location][:store_id])
    end
  end
  
  
  
  
  
  
  
  #
  # Registers
  #
  
  def addRegister
    checkAdminAccess('stores')
    redirect_to(:action => 'store', :id => Register.create!(params[:register]).store_id)
  end
  
  def edit_register
    checkAdminAccess('stores')
    @register = Register.find(params[:id])
    if params[:register] != nil
       @register.update_attributes(params[:register])
      redirect_to(:action => 'edit_register', :id => params[:id])
    end
  end
  
  def register_logs
    checkAdminAccess('stores')
    showSection('Stores', '')
    @register = Register.find(params[:id])
    @logs = RegisterLog.paginate(:register_id => @register.id, :closed_at.ne => nil, :page => params[:page], :per_page => 25, :order => 'opened_at DESC')
    @active = RegisterLog.first(:register_id => @register.id, :closed_at => nil)
  end
  
  def register_log
    showSection('Stores', '')
    @log = RegisterLog.find(params[:id])
  end
  
  # Register Templates
  
  def register_templates
    showSection('Stores', 'RegisterTemplates')
    @templates = RegisterTemplate.all(:company_id => session[:user]['company_id'])
    if params[:template] != nil
      redirect_to(:action => 'register_template', :id => RegisterTemplate.create!(params[:template]).id)
    end
  end
  
  def register_template
    @register_template = RegisterTemplate.find(params[:id])
    if params[:page] != nil
      register_template_page = RegisterTemplatePage.new(params[:page])
      @register_template.register_template_pages << RegisterTemplatePage.new(params[:page])
      redirect_to(:action => 'register_template_page', :id => register_template_page.id, :template_id => params[:id])
    end
  end
  
  def register_template_page
    @RegisterTemplate = RegisterTemplate.find(params[:template_id])
    @template_page = @RegisterTemplate.register_template_pages.select{|p| p.id.to_s == params[:id].to_s }.first
    @products = Product.all(:company_id => session[:user]['company_id'])
    if params[:product] != nil
      if !@template_page.products.include?(Product.find(params[:product]).id)
        @template_page.products << Product.find(params[:product]).id 
        @template_page.save
      end
      redirect_to(:action => 'register_template_page', :template_id => params[:template_id], :id => params[:id])
    end
  end
  
  
  
  
  
  
  
  
  
  
  #
  # Coupons
  #

  def coupon
    checkAdminAccess('marketing')
    showSection('Marketing', '')
    @coupon = Coupon.find(params[:id])
    @departments = Department.all(:department_id => nil, :company_id => session[:user]['company_id'])
    @sales = Order.paginate('order_coupons.coupon_id' => @coupon.id, :order => 'created_at DESC',:status => 'complete' ,:page => params[:page], :per_page => 10)
    @all_coupons = Coupon.all(:uses.gte => 1, :id.ne => @coupon.id, :company_id => session[:user]['company_id'])
  end

  def coupons
    checkAdminAccess('marketing')
    showSection('Marketing', 'Coupons')
    if params[:deactive] == 'yes'
      status = 0
    else
      1
    end
    @coupons = Coupon.paginate(:company_id => session[:user]['company_id'], :page => params[:page], :per_page => 20)
  end

  def add_coupon
    checkAdminAccess('marketing')
    showSection('Marketing', 'AddCoupon')
    @departments = Department.all(:department_id => nil, :company_id => session[:user]['company_id'])
  end

  def create_coupon
    checkAdminAccess('marketing')
    coupon = Coupon.new(params[:coupon])
    time_zone = Store.first.time_zone
    coupon.start_date = ("#{params[:coupon_date]['start_date(1i)']}-#{params[:coupon_date]['start_date(2i)']}-#{params[:coupon_date]['start_date(3i)']}").to_time.in_time_zone(time_zone)
    coupon.end_date = ("#{params[:coupon_end_date]['end_date(1i)']}-#{params[:coupon_end_date]['end_date(2i)']}-#{params[:coupon_end_date]['end_date(3i)']}").to_time.in_time_zone(time_zone)
    if params[:dep] != nil
      for d in params[:dep]
        coupon.departments << d.first.to_s.gsub(' ','')
      end
    end
    products = params[:products][:array].gsub(' ','').split(',')
    for p in products
      p = Product.first(:$or => [{:upc => p}, {:sku => p}, {:ean => p}])
      if p != nil
        coupon.products << p.id.to_s
      end
    end
    excluded_products = params[:excluded_products][:array].gsub(' ','').split(',')
    for e in excluded_products
      e = Product.first(:$or => [{:upc => e}, {:sku => e}, {:ean => e}])
      if e != nil
        coupon.excluded_products << e.id.to_s
      end
    end
    coupon.company_id = session[:user]['company_id']
    coupon.save
    redirect_to(:action => 'coupons')
  end

  def edit_coupon
    checkAdminAccess('marketing')
    showSection('Marketing', '')
    if params[:coupon] == nil
      @coupon = Coupon.find(params[:id])
      @departments = Department.all(:department_id => nil, :company_id => session[:user]['company_id'])
    else
      coupon = Coupon.find(params[:id])
      time_zone = Store.first.time_zone
      coupon.start_date = ("#{params[:coupon_date]['start_date(1i)']}-#{params[:coupon_date]['start_date(2i)']}-#{params[:coupon_date]['start_date(3i)']}").to_time.in_time_zone(time_zone)
      coupon.end_date = ("#{params[:coupon_end_date]['end_date(1i)']}-#{params[:coupon_end_date]['end_date(2i)']}-#{params[:coupon_end_date]['end_date(3i)']}").to_time.in_time_zone(time_zone)
      if params[:dep] != nil
        for d in params[:dep]
          coupon.departments << d.first.to_s.gsub(' ','')
        end
      end
      products = params[:products][:array].gsub(' ','').split(',')
      for p in products
        p = Product.first(:$or => [{:upc => p}, {:sku => p}, {:ean => p}])
        if p != nil
          coupon.products << p.id.to_s
        end
      end
      excluded_products = params[:excluded_products][:array].gsub(' ','').split(',')
      for e in excluded_products
        e = Product.first(:$or => [{:upc => e}, {:sku => e}, {:ean => e}])
        if e != nil
          coupon.excluded_products << e.id.to_s
        end
      end
      coupon.save
      coupon.update_attributes(params[:coupon])
      redirect_to(:action => 'coupon', :id => params[:id])
    end
  end

  def change_coupon_status
    checkAdminAccess('marketing')
    coupon = Coupon.find(params[:id])
    if params[:status] == 'inactive'
      coupon.status = 0
    else
      coupon.status = 1
    end
    coupon.save
    redirect_to(:action => 'coupon', :id => params[:id])
  end









#
# Gift Cards
#

  def giftcards
    checkAdminAccess('marketing')
    showSection('marketing', 'giftcards')
     if params[:status] == 'inactive'
       @cards = GiftCard.paginate(:company_id => session[:user]['company_id'], :status => 0, :per_page => 20, :order => 'created_at asc')
     else
       @cards = GiftCard.paginate(:company_id => session[:user]['company_id'], :status => 1, :page => params[:page], :per_page => 20, :order => 'created_at asc')
     end
  end


  def create_gift_card
    checkAdminAccess('marketing')
    if params[:gift_card] != nil
      GiftCard.newCard(params[:gift_card], params[:load])
      redirect_to(:action => 'giftcards')
    end
  end

  def gift_card
    checkAdminAccess('marketing')
     @card = GiftCard.first(:card_number => params[:id], :company_id => session[:user]['company_id'])
   end

 

   def find_gift_card
     checkAdminAccess('marketing')
     if params[:giftcard] != nil
       name = /#{params[:giftcard][:customer_name]}/i
       @giftcards = GiftCard.all(:$or => [{:card_number => params[:giftcard][:card_number], :company_id => session[:user]['company_id']}, {:customer_name => name, :company_id => session[:user]['company_id']}] )
     end
   end

   def gift_card_search
     checkAdminAccess('marketing')
     name = "/^#{params[:giftcard][:customer_name]}/"
     @giftcards = GiftCard.all(:$or => [{:card_number => params[:giftcard][:card_number], :company_id => session[:user]['company_id']}, {:customer_name => name, :company_id => session[:user]['company_id']}] )
     if @giftcards.count >= 2 || @giftcards.count == 0
       return redirect_to(:action => 'find_gift_card', :giftcard => params[:giftcard])
     end
     if @giftcards.count == 1
       redirect_to(:action => 'gift_card', :id => @giftcards.first.card_number)
     end
   end








  #
  # Reports
  #
  
  def reports
    showSection('Reports', '')
  end
  
  def sales_report 
    showSection('Reports', 'SalesRefunds') 
    @stores = Store.all(:company_id => session[:user]['company_id'])
    @employees = Employee.all(:company_id => session[:user]['company_id'])
    if params[:conditions] != nil
      start_date = 'Time.parse("' + params[:start_date] +'")'
      end_date = 'Time.parse("' + params[:end_date] +'")'
      eval("@sales = Order.paginate(:company_id => session[:user]['company_id'], :page => params[:page], :per_page => 20, :created_at.gte => #{start_date}, :created_at.lte => #{end_date}, :order => 'created_at DESC' #{ params[:conditions] })")
    end
  end








  
  #
  # Settings
  #
  
  def settings
    checkAdminAccess('all')
    showSection('Settings', 'Settings')
    @company = Company.find(session[:user]['company_id'])
    @stores = Store.all(:company_id => session[:user]['company_id'])
    @registers = Register.all(:company_id => session[:user]['company_id'])
    @domains = DomainMap.all(:company_id => session[:user]['company_id'])
  end
  
  def edit_settings
    checkAdminAccess('all')
    showSection('Settings', '')
    @company = Company.find(session[:user]['company_id'])
    if params[:company] != nil
      @company.update_attributes(params[:company])
      redirect_to(:action => 'settings')
    end
  end
  
  def mapDomain
    checkAdminAccess('all')
    if params[:domain_map] != nil
      domain = DomainMap.new(:company_id => session[:user]['company_id'])
      domain.url = params[:domain_map][:url] unless params[:domain_map][:url].blank?
      domain.store_id = params[:domain_map][:store_id] unless params[:domain_map][:store_id].blank?
      domain.register_id = params[:domain_map][:register_id] unless params[:domain_map][:register_id].blank?
      domain.save
    end
    redirect_to(:action => 'settings')
  end
  
  def deleteDomainMap
    checkAdminAccess('all')
    DomainMap.first(:id => params[:id], :company_id => session[:user]['company_id']).destroy
    redirect_to(:action => 'settings')
  end
  
  def email_settings
    checkAdminAccess('all')
    showSection('Settings', 'EmailSettings')
    @company = Company.find(session[:user]['company_id'])
  end
  
  def edit_email_settings
    checkAdminAccess('all')
    showSection('Settings', 'EmailSettings')
    @company = Company.find(session[:user]['company_id'])
    if params[:company] != nil
      @company.update_attributes(params[:company])
      redirect_to(:action => 'email_settings')
    end
  end
  
  
  
  
  
  
  
  
  
  #
  # Merchant Applications
  #
  
  def merchant_account_apply
    checkAdminAccess('all')
    @merchant_application = MerchantApplication.where(:company_id => session[:user]['company_id']).first
    if params[:merchant_application] != nil
      merchant_application = MerchantApplication.new(params[:merchant_application])
      merchant_application.company_id = session[:user]['company_id']
      merchant_application.status = 0
      merchant_application.save
      redirect_to(:action => 'merchant_account_apply', :id => merchant_application.id)
    end
  end
  
  
  
  # Updating
  
  def update_system
    for p in Product.all()
      if p.status.to_s == 'deactive'
        p.status = 0
      else
        p.status = 1
      end
      p.save
    end
  end

 
  
#
# Private
#
  
  private
  
  def check_status
    if session[:user] == nil || session[:user]['employee_id'] == ''
      redirect_to('/admin/login')
    else
      @@self = Employee.find(session[:user]['employee_id'])
      if session[:admin] == nil
        setAdminSession       
      end
      Time.zone = 'America/New_York'
    end
  end 
  
  def setAdminSession
    #@@self = employee.admin_access 
  end
  
  def showSection(section, sub)
    @section = "showSectionNew('#{section}', '#{sub}');"
  end
  
  def checkAdminAccess(section)
    if !@@self.admin_access.include?(section) && !@@self.admin_access.include?('all')
      return redirect_to('/admin')
    end
  end
end
