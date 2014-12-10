class DomainMap
  include MongoMapper::Document
  
  key :url, Lowercase
  key :company_id, ObjectId
  key :store_id, ObjectId
  key :register_id, ObjectId
  
  before_save :set_url
  
  def set_url
    self.url = self.url.gsub('http://', '').gsub('https://', '').gsub('/', '')
  end
  
end
