class Customer
	include MongoMapper::Document

  key :first_name, Lowercase
  key :last_name, Lowercase
  key :phone, Phone
  key :email, Lowercase
  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  key :country, String

  key :company_id, ObjectId
  
  key :spent, Money, :default => 0
  key :net_profit, Money, :default => 0
  key :points, Integer, :default => 0
  
  belongs_to :company
  many :orders
  many :order_returns
  #many :order_returns

  # References

  def full_name
  	"#{self.first_name.capitalize} #{self.last_name.capitalize}"
  end
  
  def full_address
    "#{self.address}<br>#{self.city}, #{self.state} #{self.zip}<br>#{self.country}"
  end

  # Actions

  def self.getCustomerInfo(q)
  		customer = Customer.first(:$or => [{:phone => q.to_s.gsub(/\D/, "").to_i}, {:email => q}])
  		if customer == nil
  			success = 'false'
  		else
  			success = 'true';
  		end
  		return "{'success' : '#{success}', 'results' : '#{customer.to_json}'}"
  end

  def self.createOrReturnCustomer(company_id, first_name, last_name, email, phone, address, city, state, zip)
  		customer = Customer.first(:$or => [{:email => email.downcase, :company_id => company_id}, {:phone => phone.gsub(/\D/, "").to_i, :company_id => company_id}])
  		if customer == nil
  			customer = Customer.first(:$or => [{:first_name => first_name.downcase, :last_name => last_name.downcase, :address => address.downcase, :zip => zip, :company_id => company_id}])
  			if customer == nil
  				customer = Customer.create!(:company_id => company_id, :first_name => first_name.downcase, :last_name => last_name.downcase, :email => email.downcase, :phone => phone.gsub(/\D/, "").to_i, :address => address.downcase, :city => city.downcase, :state => state, :zip => zip)
  			end
  		end
  		return customer
  end

  def self.add_points(customer_id, points, spent, net_profit)
  		customer = Customer.find(customer_id)
  		company = Company.find(customer.company_id)
      customer.spent += spent
      customer.net_profit += net_profit
  		customer.points += points.to_i
  		if customer.points.to_i >= company.point_payout.to_i
  			customer.createRewardCertificate(points, company.point_half_life.to_i)
  		end
      customer.save
  end

  def createRewardCertificate(points, expdate)
    GiftCard.newCard({"customer_id" => "#{self.id.to_s}","customer_name" => "#{self.full_name}", "card_number" => "CER#{Time.now.strftime('%s')}", "expdate" => "#{Time.now+expdate.days}", "company_id" => "#{self.company_id}", "employee_id" => nil, "from_order" => nil, "from_return" => nil}, {"amount" => "#{(self.points*self.company.point_value.to_f)}", "employee_id" => ""})
  end

end
