class EmployeeTimesheetHit
  include MongoMapper::EmbeddedDocument
  before_save :total_hours
  
  key :clock_in, UtcTime
  key :clock_out, UtcTime
  key :total, Money, :default => 0.00
  
  # ACTIONS
  
  def total_hours
    if self.clock_out != nil && self.clock_in != nil
      self.total = (self.clock_out - self.clock_in)/3600
    end
  end
  
  # HELPERS
  
  def time_total
    if self.clock_out != nil
      (self.clock_out - self.clock_in)/3600
    else
      (Time.now - self.clock_in)/3600
    end
  end
  
end
