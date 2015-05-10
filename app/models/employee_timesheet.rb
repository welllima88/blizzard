class EmployeeTimesheet
  include MongoMapper::Document
  before_save :total_up_hours
  safe
  
  key :timesheet_id, ObjectId
  key :employee_id, ObjectId
  key :employee_name, String
  key :date, Integer
  key :hours_worked, Money, :default => 0
  key :store_id, ObjectId
  key :store_name, String
  key :status, Integer # 0 clocked out, 1 clocked in
  
  # Pay and Earning
  key :compensation, Money
  key :compensation_type, Integer, :default => 0 # 0 = hourly, 1 = Salary
  key :earned, Money
  key :paid, Money
  key :paid_status, Boolean, :default => false
  
  # Assosiations
  many :employee_timesheet_hits
  belongs_to :timesheet
  
  # Helpers
  
  def status_human
    if self.status == 0
      return 'Clocked Out'
    else
      return 'Clocked In'
    end
  end
  
  # ACTIONS
  
  def self.find_or_new(timesheet_id, employee_id, date, store, make_new)
    
    # Find the timesheet
    time_sheet = EmployeeTimesheet.first( :employee_id => employee_id, :date => date )
    
    # Get employee
    employee = Employee.find( employee_id )
    
    # If no timesheet is found and make new = true
    if !time_sheet && make_new == true
      time_sheet = EmployeeTimesheet.create!( :timesheet_id => timesheet_id, :employee_id => employee.id, :date => date, :employee_name => employee.full_name, :compensation => employee.compensation, :compensation_type => employee.compensation_type, :store_id => store.id,  :store_name => store.name )
    end
    
    # Return the timesheet
    return time_sheet
    
  end
  
  def total_up_hours
    
    # Get total hours worked this timesheet
    self.hours_worked = self.employee_timesheet_hits.sum(&:total)
    
    # Calculate the pay
    self.calculate_pay
    
    # Is this timesheet open?
    if self.employee_timesheet_hits.select{|h| h.clock_out == nil}.count >= 1
      self.status = 1
    else
      self.status = 0
    end
    
  end
  
  def calculate_pay
    if self.compensation_type == 0
      self.earned = ( self.compensation.to_f*self.hours_worked )
    end
  end
  
end