class GiftCard
	include MongoMapper::Document
	safe

	# Model Options
	  before_create :confirm_unique
    before_save :update_totals
	
	def confirm_unique
	  if GiftCard.verify_number(self.company_id, self.card_number) == true
	    return false
    end
	end

	# Model Keys
	  key :card_number, String
    key :card_value, Money
    key :issue_date, Time
    key :orders, Array
    key :active, Boolean
    key :expdate, Time
    key :status, Integer

  # Associations
    key :company_id, ObjectId
    key :customer_id, ObjectId
    key :customer_name, String
  
  # Linking 
    many :gift_card_loads
    many :gift_card_transactions
    belongs_to :customer
  
  # Actions
  
  def self.verify_number(company_id, card_number)
	  if GiftCard.count(:company_id => company_id, :card_number => card_number) >= 1
	    return true
    end
	end
  
  # Create Giftcard
  
  def self.newCard(options, load)
    card = GiftCard.new(
      :card_number => options['card_number'],
      :card_value => 0,
      :issue_date => Time.now,
      :active => true,
      :expdate => options['expdate'].to_time,
      :company_id => options['company_id'],
      :customer_id => options['customer_id'],
      :customer_name => options['customer_name']
    )
    if card.save
      card.loadCard(options, load)
    else
      return 'error'
    end
  end
  
  # Load funds
  
  def loadCard(options, load)
    employee = Employee.find(load['employee_id'])
    if employee != nil
      employee_name = employee.full_name
    else
      employee_name = ''
    end
    self.gift_card_loads << GiftCardLoad.new(
    :load_date => Time.now, :amount => load['amount'], 
    :employee_id => load['employee_id'], 
    :employee_name => employee_name,
    :from_order => options['from_order'], 
    :from_return => options['from_return'])
    self.card_value += options['amount'].to_f
    self.save
  end
  
  # Charge Card
  
  def self.chargeCard(company_id, card_number, amount, order_id, store_id)
    gift_card = GiftCard.first(:company_id => company_id, :card_number => card_number)
    if gift_card != nil
      return gift_card.cardTransaction(amount, order_id, store_id)
    end
    false
  end
  
  def cardTransaction(charge_amount, order_id, store_id)
    if self.card_value.to_f >= charge_amount.to_f
      amount = charge_amount.to_f
    else
      amount = self.card_value.to_f
    end
    giftCardTransaction = GiftCardTransaction.new(
      :date => Time.now,
      :amount => amount,
      :order_id => order_id,
      :store_name => Store.find(store_id).name,
      :store_id => store_id
    )
    self.gift_card_transactions << giftCardTransaction
    self.save
    return '{"status" : "Approved", "charged_amount" : "' + amount.to_f.to_s + '", "remaining_balance" : "' + self.card_value.to_s + '", "exp_date" : "' + self.expdate.to_s + '", "transaction_id" : "' + giftCardTransaction.id + '", "gift_card_id" : "' + self.id + '" }'
  end
  
  # Cancel a charge
  
  def cancelCharge(transaction_id)
    transaction = self.gift_card_transactions.select{|t| t.id.to_s == transaction_id.to_s}.first
    if transaction != nil
      self.gift_card_transactions.delete_if{|t| t.id.to_s == transaction_id.to_s}
      self.save
    end
  end
  
  # Add Customer
  
  def self.addCustomerToCard(customer_id, card_number)
    card = GiftCard.first(:card_number => card_number)
    if card != nil
      card.customer_id = customer_id
      card.customer_name = Customer.find(customer_id).full_name
      if card.save
        # Associate all sales with newly added customer
        for t in card.gift_card_transactions
          order = Order.find(t.order_id)
          if order.customer_id.blank?
            order.customer_id = customer_id
            order.customer_name = Customer.find(customer_id).full_name
            order.save
          end
        end
      end
    end
  end
  
  # Before Save
  
  def update_totals
    self.card_value = self.gift_card_loads.to_a.sum(&:amount)-self.gift_card_transactions.to_a.sum(&:amount)
    if self.card_value >= 0.01
      self.status = 1
    else
      self.status = 0
    end
  end

end