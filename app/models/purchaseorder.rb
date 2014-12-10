class Purchaseorder
  include MongoMapper::Document
  include ActionView::Helpers::NumberHelper
  
  before_save :total_up
  #after_save :all_up
  before_create :change_id
  
  def change_id
    self._id = "#{Time.now.in_time_zone('UTC').strftime("%y%j%H%M%S")}#{self.vendor_id}"
  end
  
  key :vendor_id, ObjectId
  key :vendor_name, String
  key :vendor_account_number, String
  key :status, Integer, :default => 0
  key :cost, Money, :default => 0
  key :shipping_cost, Money, :default => 0
  key :discount_amount, Money, :default => 0
  key :discount_percent, Integer, :default => 0
  key :total, Money
  key :amount_paid, Money
  key :created_at, Time, :default => Time.now 
  key :employee_id, ObjectId
  key :employee_name, String
  key :approval_employee_id, ObjectId
  key :approval_employee_name, String
  key :all_recieved, String
  key :po_number, String
  key :emailed, Integer
  key :comments, String
  
  # Shipping Information
  key :shipping_address, String
  key :shipping_city, String
  key :shipping_state, String
  key :shipping_zip, String
  
  key :tax_rate, Money
  
  key :signed_by, String
  key :signed_date, Time, :default => Time.now
  
  many :po_items
  many :po_payments
  belongs_to :vendor
  key :company_id
  belongs_to :company
  
  def status_human
    return ['New', 'Submitted', 'Open', 'Complete'][self.status]
  end
  
  def emailed_human
    return ['No', 'Yes'][self.emailed]
  end
  
  def tax_decimal
    "#{(self.tax_rate * 0.01)}"
  end
  
  def subtotal
    self.po_items.to_a.sum(&:total)
  end
  
  def total_discount
    ((self.cost+self.shipping_cost)*self.discount_percent/100)+self.discount_amount
  end
  
  def receive_item(employeeid, item)
    item
  end
  
  def total_up
    if self.shipping_cost.blank?
      self.shipping_cost = 0
    end
    if self.discount_amount.blank?
      self.discount_amount = 0
    end
    if self.discount_percent.blank?
      self.discount_percent = 0
    end
    self.cost = self.po_items.to_a.sum(&:total)
    self.total = (self.cost+self.shipping_cost)-((self.cost+self.shipping_cost)*self.discount_percent/100)-self.discount_amount
    #check if all are recieved
    self.all_up
  end
  
  def all_up
    if self.status.to_i != 3 && self.status.to_i != 0 && self.all_recieved != 'yes'
      if self.po_items.select{|i| i.all_received == 'no' || i.all_received == nil}.count == 0
        self.all_recieved = 'yes'
      end
    end
    if self.po_items.count >= 1
      self.check_complete
    end
  end
  
  def check_complete
    if self.total <= self.amount_paid.to_f && self.all_recieved == 'yes' && self.status.to_i != 3 && self.status.to_i != 0
      self.status = 3
    end
  end
  
  def add_to_po(item_id, qty)
    product = Product.find(item_id)
    thing = self.po_items.select{|i| i.product_id == product.id}
    if thing.count > 0
      item = self.po_items.find(thing.first.id)
      item.qty += qty.to_i
    else
      item = PoItem.new
      item.qty = qty.to_i
      item.all_received = 'no'
    end
    product.on_order += qty.to_i
    item.name = product.name
    item.product_id = product.id
    item.manufacturer_id = product.manufacturer_id
    if !product.manufacturer_id.blank?
      item.manufacturer_name = product.manufacturer.name
    end
    item.upc = product.upc
    item.vendor_sku = product.m_sku
    item.cost = product.cost
    item.total = item.cost*qty.to_i
    item.manufacturer_sku = product.m_sku
    if thing.count < 1
      self.po_items << item
    end
    self.save
    product.save
  end
  
  def add_payment(payment_type, amount, transaction_id)
    payment = PoPayment.new
    payment.payment_type = payment_type
    payment.payment_name = payment.payment_type.gsub("_", "").capitalize
    payment.amount = amount
    payment.created_at = Time.now
    payment.transaction_id = transaction_id
    self.po_payments << payment
    self.amount_paid = self.po_payments.to_a.sum(&:amount)
    self.save
    "#{self.id}"
  end
  
  def self.submit_to_vendor(po_id, employee_full_name, company_id, from_email)
    purchase_order = Purchaseorder.find(po_id)
    if purchase_order.vendor.po_email != nil && from_email != nil && from_email != ''
      purchase_order.send_po_to_vendor(purchase_order.vendor_id, from_email, company_id)
      purchase_order.emailed = 1
    else
      purchase_order.emailed = 0
    end
    purchase_order.signed_by = employee_full_name
    purchase_order.signed_date = Time.now
    purchase_order.status = 1
    purchase_order.save
    for i in purchase_order.po_items
      product = Product.find(i.product_id)
      product.on_order += i.qty.to_i
      product.save
    end
    "#{purchase_order.emailed}"
  end
  
  def send_po_to_vendor(vendor_id, from_email, company_id)
    CompanyMailer.vendor_purchase_order(Vendor.find(vendor_id), self, from_email, Company.find(company_id)).deliver
  end
  
  #
  # Rendering
  #
  
  def renderedPdf(company_id, vendor_id)
    @company = Company.find(company_id)
    @vendor = Vendor.find(vendor_id)
    pdf = Prawn::Document.new
    # Variables
    company_name = "#{@company.company_name}"

    company_address = "#{@company.company_address}
    #{@company.company_city}, #{@company.company_state} #{@company.company_zip}"

    po_date = "#{self.created_at.strftime('%B %d, %Y')}"
    po_number = "#{self.id}"

    vendor_address = "#{@vendor.name}
    #{@vendor.address}
    #{@vendor.city}, #{@vendor.state} #{@vendor.zip}"

    shipping_address = "#{@company.company_name}
    #{self.shipping_address}
    #{self.shipping_city}, #{self.shipping_state} #{self.shipping_zip}"

    pdf.bounding_box([0,730], :width => 300) do
        pdf.text "Purchase Order", :size => 20, :spacing => 5
    end

    pdf.bounding_box([0,700], :width => 200) do
        pdf.text company_name, :size => 12
        pdf.text company_address, :size => 12
    end

    pdf.bounding_box([300,700], :width => 200) do
        pdf.text "Date: #{po_date}", :size => 12
        pdf.text "PO ID: #{po_number}", :size => 12
    end

    pdf.bounding_box([0,620], :width => 200) do
        pdf.text "VENDOR:", :size => 14
        pdf.text vendor_address, :size => 12
    end

    pdf.bounding_box([300,620], :width => 200) do
        pdf.text "SHIP TO:", :size => 14
        pdf.text shipping_address, :size => 12
    end

    pdf.move_down 10

    items = [["Product Name", "SKU", "UPC", "QTY","Price","Total"]] +
    self.po_items.map do |item|
      [
        item.name,
        item.vendor_sku,
        item.upc,
        item.qty,
        number_to_currency(item.cost),
        number_to_currency(item.cost.to_i*item.qty.to_i)
      ]
    end

    totals = [
        ["SUBTOTAL", "#{number_to_currency self.subtotal}"],
        ["SHIPPING COST", "#{number_to_currency self.shipping_cost}"],
        ["DISCOUNT", "#{number_to_currency self.total_discount}"],
        ["TOTAL", "#{number_to_currency self.total}"]
    
      ]

    pdf.table(items, :width=>500) do
      style(row(0), :background_color => 'eeeeee')
    end

    pdf.move_down 10

    pdf.table(totals, :width=>300) do
    end

    pdf.move_down 20

    pdf.text "<u><b>SIGNED BY:</b> #{self.signed_by}      <b>DATE:</b> #{self.signed_date.strftime('%B %d, %Y')}</u>", :inline_format => true, :align => :right
    
    pdf.render
  end
  
end