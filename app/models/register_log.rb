class RegisterLog
  include MongoMapper::Document
  RegisterLog.ensure_index(:register_id)
  
  # General
  key :status, Integer
  
  # Open Till
  key :opened_at, Time
  key :opening_employee, String
  key :opening_employee_id, ObjectId
  key :opening_amount, Money
  
  # Closing Till
  key :closed_at, Time
  key :closing_employee, String
  key :closing_employee_id, ObjectId
  key :closing_amount, Money
  
  # Discrepencies Reported
  key :discrepencies, Boolean
  
  # Associations
  key :register_id, ObjectId
  belongs_to :register
  
  many :register_log_transactions
  
  # Version 2 Legacy
  def self.open_register(register)
    register_log = RegisterLog.new()
    register_log.status = 1
    register_log.opened_at = Time.now
    register_log.opening_amount = register.till
    register_log.opening_employee = register.current_employee
    register_log.opening_employee_id = register.current_employee_id
    register_log.discrepencies = false
    register_log.register_id = register.id
    register_log.save
  end
  
  # Version 3
  def self.openRegister(register, timestamp)
    register_log = RegisterLog.new()
    register_log.status = 1
    register_log.opened_at = timestamp
    register_log.opening_amount = register.till
    register_log.opening_employee = register.current_employee
    register_log.opening_employee_id = register.current_employee_id
    register_log.discrepencies = false
    register_log.register_id = register.id
    register_log.save
  end
  
  def self.register_transaction(payment_id, register_id, amount, payment_type, employee_id, employee_name, order_id, current_till, transaction_type, created_at)
    register_log = RegisterLog.first(:register_id => register_id, :status => 1)
    if register_log
      register_log_transaction = RegisterLogTransaction.new(:amount => amount,
                                                            :payment_id => payment_id,
                                                            :payment_type => payment_type,
                                                            :employee_id => employee_id,
                                                            :employee_name => employee_name,
                                                            :new_till => current_till,
                                                            :parent_id => order_id,
                                                            :transaction_type => transaction_type,
                                                            :created_at => created_at)                          
      register_log.register_log_transactions << register_log_transaction
      register_log.save
    end
  end
  
  def self.close_register(register, timestamp)
    register_log = RegisterLog.first(:register_id => register.id, :status => 1)
    register_log.status = 0
    register_log.closed_at = Time.now
    register_log.closing_amount = register.till
    register_log.closing_employee = register.current_employee
    register_log.closing_employee_id = register.current_employee_id
    register_log.save
  end
  
end