class Timesheet
  include MongoMapper::Document
  
  key :date, Integer #YYYYMMDD
  key :store_id, ObjectId
  key :company_id, ObjectId
  
  many :employee_timesheets
  belongs_to :store
  belongs_to :comapny
  
  # ACTIONS
  
  Time.zone = 'UTC'  
  
  def self.punch_clock(store_id, utc_time, employee_id)
    
    # Find the store
    store = Store.find(store_id)
    
    # Convert Javascript time to Ruby
    time = Time.at( utc_time ).in_time_zone( store.time_zone )
    
    # Find or create a new timesheet
    timesheet = Timesheet.find_or_create_time_sheet( store, utc_time )
    
    # Get employees timesheet
    employee_timesheet = Timesheet.get_employee_session( time, employee_id, store, timesheet.id )
    
    # If there is an open session, close it. If not, open one
    open_session = employee_timesheet.employee_timesheet_hits.select{|s| s.clock_out == nil}.first
    if open_session
      open_session.clock_out = time
      result = 'Out'
    else
      employee_timesheet.employee_timesheet_hits << EmployeeTimesheetHit.new( :clock_in => time )
      result = 'In'
    end
    
    employee_timesheet.save
    
    # Return human readable result
    return result
    
  end
  
  
  def self.find_or_create_time_sheet(store, utc_date)
    
    # Convert date to YYYYMMDD format in the locations time zone
    converted_time = Time.at( utc_date ).in_time_zone( store.time_zone ).strftime( '%Y%m%d' ).to_i
    
    # Find the open timesheet
    timesheet = Timesheet.first( :store_id => store.id, :date => converted_time )
    
    # If timesheet doesnt exist, create one
    if !timesheet
      timesheet = Timesheet.create!( :company_id => store.company_id, :store_id => store.id, :date => converted_time )
    end
    puts timesheet.to_json
    # Return the timesheet
    return timesheet
    
  end
  
  
  def self.get_employee_session(time, employee_id, store, timesheet_id)
    
    # Is there an open sheet from yesterday?
    yesterday_date = (time-1.day).strftime("%Y%m%d").to_i
    yesterdays_session = EmployeeTimesheet.find_or_new( timesheet_id, employee_id, yesterday_date, store, false )
    
    # If there is a timesheet from yesterday, is there an unclosed session?
    if yesterdays_session
      if yesterdays_session.employee_timesheet_hits.select{ |s| s.clock_out == nil }.first
        return yesterdays_session
      end
    end
    
    # if there is no closed sessions from yesterday, Return todays
    return EmployeeTimesheet.find_or_new( timesheet_id, employee_id, time.strftime("%Y%m%d").to_i, store, true )
    
  end
  
    
end