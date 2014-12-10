class MasterInfo
  include MongoMapper::Document
  safe 
  
  # Evendra Point of Sale
  #
  # This is the mater document and should not be altered.
  # This file contains information that is applicable to all companies, not a per company basis
  # 
   
  
  # General Evendra Information
  key :company_count, Integer, :default => 0
  
  # This is extremley important!!!
  
  def next_company_id
    self.company_count += 1
    self.save
    return self.company_count
  end 
  
end