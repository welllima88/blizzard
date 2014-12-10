class Commission
  include MongoMapper::Document
  
  key :employee_id, ObjectId
  key :employee_name, String
  key :order_id, ObjectId
  
  key :commission, Money
  key :order_total, String
  
  many :commission_items


end
