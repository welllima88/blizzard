class CreateAccountController < ApplicationController
  
  protect_from_forgery :except => [:new_account, :index]
  
  def index
    @company = Company.find(session[:user]['company_id'])
  end
  
  def new_account
    session[:user] = nil
    company = Company.create!(params[:company])
    employee = Employee.new(params[:employee])
    employee.company_id = company.id.to_s
    employee.super_admin = true
    employee.save
    session[:user] = {'company_id' => employee.company_id, 'employee_id' => employee.id, 'employee_name' => employee.full_name, 'store_id' => '', 'register_id' => ''}
    CompanyMailer.newAccount(company.id.to_s, employee.username, employee.email).deliver
    redirect_to(:action => 'index')
  end
  
end
