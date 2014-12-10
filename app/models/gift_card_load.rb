class GiftCardLoad
  include MongoMapper::EmbeddedDocument
  
  key :load_date, Time
  key :amount, Money
  key :employee_id, ObjectId
  key :employee_name, String, :default => ''
  key :from_order, ObjectId # sale the gift card was purchased from
  key :from_return, ObjectId # return the gift card was provided by

end