pdf = Prawn::Document.new
# Variables
company_name = "#{@company.company_name}"

company_address = "#{@company.company_address}
#{@company.company_city}, #{@company.company_state} #{@company.company_zip}"

po_date = "#{@po.created_at.strftime('%B %d, %Y')}"
po_number = "#{@po.id}"

vendor_address = "#{@vendor.name}
#{@vendor.address}
#{@vendor.city}, #{@vendor.state} #{@vendor.zip}"

shipping_address = "#{@company.company_name}
#{@po.shipping_address}
#{@po.shipping_city}, #{@po.shipping_state} #{@po.shipping_zip}"

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
@po.po_items.map do |item|
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
    ["SUBTOTAL", "#{number_to_currency @po.subtotal}"],
    ["SHIPPING COST", "#{number_to_currency @po.shipping_cost}"],
    ["DISCOUNT", "#{number_to_currency @po.total_discount}"],
    ["TOTAL", "#{number_to_currency @po.total}"]

  ]

pdf.table(items, :width=>500) do
  style(row(0), :background_color => 'eeeeee')
end

pdf.move_down 10

pdf.table(totals, :width=>300) do
end

pdf.move_down 20

pdf.text "<u><b>SIGNED BY:</b> #{@po.signed_by}      <b>DATE:</b> #{@po.signed_date.strftime('%B %d, %Y')}</u>", :inline_format => true, :align => :right

pdf.render