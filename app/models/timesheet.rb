class Timesheet
  include MongoMapper::Document
  
  key :date, String
  key :store_id, ObjectId
  key :company_id, ObjectId
  
  many :employee_timesheets
  belongs_to :store
  belongs_to :comapny
  
  # ACTIONS
  
  Time.zone = 'UTC'
  
  def self.find_or_create_time_sheet(store_id, date)
    timesheet = Timesheet.first(:store_id => store_id, :date => date.to_s)
    if timesheet == nil
      timesheet = Timesheet.create!(:company_id => Store.find(store_id).company_id, :store_id => store_id, :date => date.to_s)
    end
    return timesheet
  end
  
  def self.punchClock(store_id, date_time, employee_id)
    Time.zone = Store.find(store_id).time_zone
    time = Time.zone.parse("#{date_time}")
    timehseet = Timesheet.find_or_create_time_sheet(store_id, Timesheet.formatDate(date_time))
    employee_timesheet = Timesheet.get_session(time, employee_id, store_id, timehseet.id)
    session = employee_timesheet.employee_timesheet_hits.select{|s| s.clock_out == nil}.first
    if session != nil
      session.clock_out = time
      clock = 'Out'
    else
      session = EmployeeTimesheetHit.new(:clock_in => time)
      employee_timesheet.employee_timesheet_hits << session
      clock = 'In'
    end
    if employee_timesheet.save
      return clock
    else
      return false
    end
  end
  
  # HELPERS
  
  def self.formatDate(date_time)
    return "#{date_time[0]}#{date_time[1]}#{date_time[2]}#{date_time[3]}#{date_time[04]}#{date_time[5]}#{date_time[6]}#{date_time[7]}"
  end
  
  def self.get_session(time, employee_id, store_id, timesheet_id)
    yesterday = (time-1.day).strftime("%Y%m%d")
    #yesterdays_session = EmployeeTimesheet.first(:date => yesterday, :employee => employee_id)
     yesterdays_session = EmployeeTimesheet.find_or_new(timesheet_id, employee_id, yesterday, store_id, false)
    if yesterdays_session != nil
      session = yesterdays_session.employee_timesheet_hits.select{|s| s.clock_out == nil}.first
      if session != nil
        return yesterdays_session
      end
    end
    today = EmployeeTimesheet.find_or_new(timesheet_id, employee_id, time.strftime("%Y%m%d").to_s, store_id, true)
    return today
  end
    
  
end