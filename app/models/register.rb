class Register
  include MongoMapper::Document
  Register.ensure_index(:company_id)
  
  # Change the ID to something short and unique
  before_create :change_id
  
  def change_id
    self.id = "#{self.store_id}#{(Register.where(:company_id => self.company_id).count.to_i+1).to_s}R"
    self.status = 0
  end
  
  # General
  key :name, String
  key :till, Money, :default => 0
  key :current_employee_id, ObjectId
  key :current_employee, String
  key :status, Integer
  
  # Register Template
  key :register_template_id, ObjectId
  
  # Associations
  key :company_id, ObjectId
  key :store_id, ObjectId
  key :register_template_id, ObjectId
  belongs_to :store
  belongs_to :company
  
  def open_register(till, user_session)
    self.till = till
    self.current_employee = user_session['employee_name']
    self.status = 1
    self.save
    RegisterLog.open_register(self)
  end
  
  def close_registerold(till, employee)
    if self.till != till
      RegisterLog.discrepency(self.till, till, employee)
      
    end
    self.current_employee = "#{employee.first_name.capitalize} #{employee.last_name.capitalize}"
    self.status = open
    self.save
  end
  
  def updateTill(amount)
    self.till = amount.to_f
    self.save
  end
  
  def addToTill(employee_id, employee_name, amount, current_till, timestamp)
    # Called from: sync controller
    RegisterLog.register_transaction(nil, self.id, amount, nil, employee_id, employee_name, "add#{Time.now.to_i}reg#{self.id}", current_till, 2, timestamp)
    self.till = current_till
    self.save
  end
  
  def removeFromTill(employee_id, employee_name, amount, current_till)
    # Called from: sync controller
    RegisterLog.register_transaction(nil, self.id, amount, nil, employee_id, employee_name, "sub#{Time.now.to_i}reg#{self.id}", current_till, 3, timestamp)
    self.till = current_till
    self.save
  end
  
  def verifyTill(employee_id, employee_name, amount, current_till, timestamp)
    RegisterLog.register_transaction(nil, self.id, amount, nil, employee_id, employee_name, "ver#{Time.now.to_i}reg#{self.id}", current_till, 4, timestamp)
    self.till = current_till
    self.save
  end
  
  def closeRegister(employee_id, employee_name, amount, till, timestamp)
    self.till = till
    self.current_employee = employee_name
    self.current_employee_id = employee_id
    self.status = 0
    self.save
    RegisterLog.close_register(self, timestamp)
  end
  
  def openRegister(employee_id, employee_name, amount, till, timestamp)
    self.till = till
    self.current_employee = employee_name
    self.current_employee_id = employee_id
    self.status = 1
    self.save
    RegisterLog.openRegister(self, timestamp)
  end
  
  # Helpers
  
  def human_status
    if self.status == 1
      return "Open"
    else
      return "Closed"
    end
  end
  
  # Touch Templates
  
  def template_data
    data = "";
    page_number = 0
    if self.register_template_id != nil
      @register_template = RegisterTemplate.find(self.register_template_id)
      for page in @register_template.register_template_pages
        data += "<div class='itemPage' id='page#{page_number}'>"
        for p in page.products
          data += "<div class='itemButton' onclick='addItemToSale(\\\"#{p.to_s}\\\", 1)'><p>#{Product.find(p).name}</p></div>"
        end
        data += "</div>"
        page_number+=1
      end
    else
      page_number = 0
      product_count = 0
      for p in Product.all(:company_id => self.company_id)
        product_count += 1
        if product_count >= 21
          product_count = 1
          page_number += 1
        end
        if product_count == 1
          data += "<div class='itemPage' id='page#{page_number}'>"
        end
        data += "<div class='itemButton' onclick='addItemToSale(\\\"#{p.id.to_s}\\\", 1)'><p>#{p.name}</p></div>"
        if product_count == 20
          data += "</div>"
        end
      end
    end
    return data
  end
  
  def register_page_buttons
    data = ''
    page_number = 0
    if self.register_template_id != nil
      for page in RegisterTemplate.find(self.register_template_id).register_template_pages
        data += "<div class='pageButton' id='pageButton#{page_number}' onclick='switchToPage(\\\"#{page_number}\\\");'>#{page.name}</div>"
        page_number+=1
      end
    else
      product_count = Product.all(:company_id => self.company_id).count
      page_number = 0
      (product_count/20).times do
        data += "<div class='pageButton' id='pageButton#{page_number}' onclick='switchToPage(\\\"#{page_number}\\\");'>Page #{page_number+1}</div>"
        product_count -= 20
        page_number +=1
      end
      if product_count >= 0.01
        data += "<div class='pageButton' id='pageButton#{page_number}' onclick='switchToPage(\\\"#{page_number}\\\");'>Page #{page_number+1}</div>"
      end
    end
    return data    
  end
  
  
end