class RegisterTemplate
  include MongoMapper::Document
  key :name, String
  many :register_template_pages
  
  def template_data
    data = "";
    page_number = 0
    for page in self.register_template_pages
      data += "<div class='itemPage' id='page#{page_number}'>"
      for p in page.products
        data += "<div class='itemButton' onclick='addItemToSale(\\\"#{p.to_s}\\\", 1)'><p>#{Product.find(p).name}</p></div>"
      end
      data += "</div>"
      page_number+=1
    end
    return data
  end
  
  def register_page_buttons
    data = "";
    page_number = 0
    for page in self.register_template_pages
      data += "<div class='pageButton' id='pageButton#{page_number}' onclick='switchToPage(\\\"#{page_number}\\\");'>#{page.name}</div>"
      page_number+=1
    end
    return data
  end
    
end
