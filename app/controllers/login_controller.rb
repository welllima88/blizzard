class LoginController < ApplicationController
  
  before_filter :check_status, :except => ['admin_login', 'complete_logoff']
  
  def index
    if session[:user] != nil
      if session[:user]['company_id'].to_s.length >= 1 && session[:user]['employee_id'].to_s.length >= 1
        return redirect_to(:action => 'select_store')
      end
    end
    if params[:employee] != nil
      logged_in_user = Employee.authenticate(params[:employee][:company_id], params[:employee][:username], params[:employee][:password])
      if logged_in_user != nil
        if session[:user] != nil
          session[:user] = {'company_id' => logged_in_user.company_id, 'employee_id' => logged_in_user.id, 'employee_name' => logged_in_user.full_name, 'store_id' => session[:user]['store_id'] || nil, 'register_id' => session[:user]['register_id']}
        else
          session[:user] = {'company_id' => logged_in_user.company_id, 'employee_id' => logged_in_user.id, 'employee_name' => logged_in_user.full_name, 'store_id' => '', 'register_id' => ''}
        end
        redirect_to('/admin')
      else
        redirect_to('/login')
      end
    end
  end
  
  def admin_login
    if params[:employee] != nil
      logged_in_user = Employee.authenticate(params[:employee][:company_id], params[:employee][:username], params[:employee][:password])
      if logged_in_user != nil
        session[:user] = {'company_id' => logged_in_user.company_id, 'employee_id' => logged_in_user.id, 'employee_name' => logged_in_user.full_name, 'store_id' => '', 'tax_rate' => '', 'register_id' => ''}
        redirect_to('/admin')
      else
        redirect_to('/admin/login')
      end
    end
  end
  
  
  
  #
  # Forgot Password
  #
  
  def forgot_password
    if params[:company_id] != nil
      @employee = Employee.first(:company_id => params[:company_id].to_s, :$or => [{:username => params[:username]}, {:email => params[:email]}])
      if @employee != nil
        @employee.resetPassword
        flash[:notifi] = 'Please check your email to reset your password.'
        redirect_to('/login')
      end
    end
  end
  
  def reset_code
    if params[:reset_code] != nil
      employee = Employee.first(:reset_key => params[:reset_code])
      if employee != nil
        employee.new_password = params[:new_password]
        employee.save
        flash[:notifi] = 'Your password has been reset'
        redirect_to('/login')
      end
    end
  end
  
  #
  #
  #
  
  def complete_logoff
    session[:user] = nil
    redirect_to(:action => 'index')
  end
  
  def logoff
    session[:user]['register_id'] = nil
    session[:user]['store_id'] = nil
    session[:user]['employee_id'] = nil
    redirect_to('/login')
  end
  
  def log_off_register
    session[:user]['register_id'] = nil
    redirect_to('/login')
  end
  
  def log_off_store
    session[:user]['register_id'] = nil
    session[:user]['store_id'] = nil
    redirect_to('/login')
  end
  
  def log_off_employee
    session[:user]['employee_id'] = nil
    redirect_to('/login')
  end
  
  # Private Area
  private
  
  def check_status
    if session[:user] != nil
      session[:user] = {'company_id' => session[:user]['company_id'], 'employee_id' => session[:user]['employee_id'], 'employee_name' => session[:user]['employee_name'], 'store_id' => session[:user]['store_id'], 'register_id' => session[:user]['register_id']}
    else
      session[:user] = {'company_id' => '', 'employee_id' => '', 'employee_name' => '', 'store_id' => '', 'register_id' => ''}
    end
  end
  
end
