class UtcTime < Time
   def self.to_mongo(value)
     value.utc
   end

   def self.from_mongo(value)
     if value != nil
       value.utc
     end
   end
end