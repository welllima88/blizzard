class Manufacturer
  include MongoMapper::Document
  
  key :name, Lowercase
  key :phone, Phone
  key :website, String
  key :company_id, ObjectId
  
  many :products
  
end