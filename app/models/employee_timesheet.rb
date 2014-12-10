class EmployeeTimesheet
  include MongoMapper::Document
  before_save :total_up_hours
  safe
  
  key :timesheet_id, ObjectId
  key :employee_id, ObjectId
  key :employee_name, String
  key :date, String
  key :hours_worked, Money, :default => 0
  key :store_id, ObjectId
  key :store_name, String
  key :status, Integer # 0 clocked out, 1 clocked in
  
  # Pay and Earning
  key :compensation, Money
  key :compensation_type, String, :default => 'hourly'
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
  
  def self.find_or_new(timesheet_id, employee_id, date, store_id, make_new)
    # Add pay rate
    time_sheet = EmployeeTimesheet.first(:employee_id => employee_id, :date => date)
    employee = Employee.find(employee_id)
    if time_sheet == nil && make_new == true
      time_sheet = EmployeeTimesheet.create!(:timesheet_id => timesheet_id, :employee_id => employee.id, :date => date, :employee_name => employee.full_name, :compensation => employee.compensation, :compensation_type => employee.compensation_type, :store_id => store_id,  :store_name => Store.find(store_id).name)
    end
    return time_sheet
  end
  
  def total_up_hours
    hours_worked = 0
    for hit in self.employee_timesheet_hits
      hours_worked += hit.time_total
    end
    self.hours_worked = hours_worked
    self.calculate_pay
    if self.employee_timesheet_hits.select{|h| h.clock_out == nil}.count >= 1
      self.status = 1
    else
      self.status = 0
    end
  end
  
  def calculate_pay
    if self.compensation_type == 'hourly'
      self.earned = (self.compensation.to_f*self.hours_worked)
    end
  end
  
end