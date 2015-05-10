class Lowercase < String
  def self.to_mongo(value)
     if !value.blank?
       value.downcase
     end
   end

   def self.from_mongo(value)
     value
   end
end