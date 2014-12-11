class ManageController < ApplicationController
  
  def allCompanies
    @companies = Company.paginate(:per_page => 20, :page => params[:page])
  end
  
  def company
    @company = Company.find(params[:id])
    @sales = Order.paginate(:company_id => @company.id, :per_page => 5, :page => params[:page_sales])
    @stores = Store.all(:company_id => @company.id)
    @employees = Employee.paginate(:company_id => @company.id, :per_page => 5, :page => params[:page_employees])
  end
  
  def login_as_employee
    employee = Employee.find(params[:id])
    session[:user] = {'company_id' => employee.company_id, 'employee_id' => employee.id, 'employee_name' => employee.full_name, 'store_id' => '', 'register_id' => ''}
    redirect_to(:controller => 'admin', :action => 'sales')
  end
  
  def allSales
    @sales = Order.paginate(:order => 'created_at DESC', :per_page => 25, :page => params[:page])
  end
  
  def updatePassword
    @company = Company.find(params[:company_id])
    @employee = Employee.find(params[:employee_id])
    if params[:employee] != nil
      @employee.new_password = params[:employee][:new_password]
      @employee.save
    end
    redirect_to(:action => 'company', :id => params[:company_id])
  end
  
  #
  # Merchant Applications
  #
  
  def applications
    @apps = MerchantApplication.paginate(:per_page => 20, :page => params[:page])
  end
  
  def merchant_application
    @merchant_application = MerchantApplication.find(params[:id])
  end
  
  
  #
  # Old Below
  #
  
  def showCompanies
    @companies = Company.paginate(:per_page => 20, :page => params[:page])
  end
  
  def viewCompany
    @company = Company.find(params[:id])
    @stores = Store.all(:company_id => @company.id)
    @registers = Register.all(:company_id => @company.id)
    @domains = DomainMap.all(:company_id => @company.id)
  end
  
  def method_name
    
  end
  
  # Demo Fixing
  
  def resetDemoUser
    user = Employee.first(:company_id => '1')
    user.username = 'jsmith'
    user.new_password = 'password'
    user.save
    redirect_to('/')
  end
  
  #
  #
  # Fixes
  #
  
  def fixProductInventories
    for c in Company.all()
      stores = Store.all(:company_id => c.id)
      products = Product.all(:company_id => c.id)
      for p in products
        for s in stores
          product_inventory = p.product_inventorys.select{|pi| pi.store_id.to_s == s.id.to_s}.first
          if product_inventory == nil
            product_inventory = ProductInventory.new(:store_id => s.id, :qty => 0)
            p.product_inventorys << product_inventory
          end
        end
        p.save
      end
    end
  end
  
  def fixRegisterLogTimeStamps
    for c in Company.all()
      
      for r in Register.all(:company_id => c.id)
        
        for rl in RegisterLog.all(:register_id => r.id)
          last_log = rl.opened_at
          for rlt in rl.register_log_transactions
            
            if rlt.transaction_type == 0
              rlt.created_at = Order.find(rlt.parent_id).created_at
            end
            
            if rlt.transaction_type == 1
              rlt.created_at = OrderReturn.find(rlt.parent_id).created_at
            end
            
            if rlt.transaction_type >= 2
              rlt.created_at = last_log+5
            end
            last_log = rlt.created_at
          end
          rl.save
        end
        
      end
      
    end
  end
  
end
