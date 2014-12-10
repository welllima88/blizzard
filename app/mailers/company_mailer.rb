class CompanyMailer < ActionMailer::Base
  
  def newAccount(company_id, username, email)
    @company_id = company_id
    @username = username
    headers['Errors-To'] = "support@evendra.com"
    headers['Return-Path'] = "support@evendra.com"
    headers['X-Domain'] = "evendra.com"
    headers['MIME-Version'] = "1.0"
    headers['Content-type'] = "text/html; charset=iso-8859-1"
    mail(:from => 'support@evendra.com', :to => "#{email}", :subject => 'Welcome to Evendra', :bcc => 'sperry@evendra.com')
  end
  
  def reset_password(employee)
    @employee = employee
    headers['Errors-To'] = "support@evendra.com"
    headers['Return-Path'] = "support@evendra.com"
    headers['X-Domain'] = "evendra.com"
    headers['MIME-Version'] = "1.0"
    headers['Content-type'] = "text/html; charset=iso-8859-1"
    mail(:from => 'support@evendra.com', :to => "#{employee.email}", :subject => 'Evendra Password Reset')
  end
  
  def method_name
    attachments['terms.pdf'] = File.read('/path/terms.pdf')
  end
  
  def vendor_purchase_order(vendor, po, from_email, company)
    @company = company
    @vendor = vendor
    @po = po
    #po_pdf_view = Purchaseorder.new(@po)
    po_pdf_content = @po.renderedPdf(company.id, vendor.id)
    attachments["#{@po.id}.pdf"] = {
      mime_type: 'application/pdf',
      content: po_pdf_content
    }
    mail(:from => from_email, :to => vendor.po_email, :subject => "New Purchase Order: #{@po.id}")
  end
  
  
  def report(report_id, recipient_email)
      report = Report.find(report_id)
      report_pdf_view = ReportPdf.new(report)
      report_pdf_content = report_pdf_view.render()
      attachments["#{@po.id}.pdf"] = {
        mime_type: 'application/pdf',
        content: report_pdf_content
      }
      mail(:to => recipient_email, :subject => "Your report is attached")
  end
  
  
  # Emailed Receipts
  
  def email_receipt(company, customer, order)
    headers['Errors-To'] = company.from_email
    headers['Return-Path'] = company.from_email
    headers['X-Domain'] = company.from_email.split('@')[1]
    headers['MIME-Version'] = "1.0"
    headers['Content-type'] = "text/html; charset=iso-8859-1"
    delivery_options = {
      user_name: company.smtp_user,
      password: company.smtp_pass,
      address: company.smtp_host,
      port: company.smtp_port,
      authentication: 'plain',
      enable_starttls_auto: true
    }
    mail(:from => company.from_email, :to => "#{customer.email}", :subject => "#{company.company_name} e-Receipt", delivery_method_options: delivery_options)
  end
  
end
