class Department
  include MongoMapper::Document
  
  key :name, String
  key :department_id, ObjectId
  key :sub_departments, Array
  key :number_of_items, Integer, :default => 0
  
  key :company_id, ObjectId
  
  belongs_to :department
  many :departments
  
end
