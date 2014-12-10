class RegisterTemplatePage
  include MongoMapper::Document
  
  key :name, String
  key :page_order, Integer
  key :products, Array
  
end
