// Variables

	var current_user = JSON.parse(localStorage.getItem('current_user'));
	var current_company = JSON.parse(localStorage.getItem('current_company'));
	var all_stores = JSON.parse(localStorage.getItem('all_stores'));
	var current_store = JSON.parse(localStorage.getItem('current_store'));
	var all_registers = JSON.parse(localStorage.getItem('all_registers'));
	var current_register = JSON.parse(localStorage.getItem('current_register'));
	var current_page = localStorage.getItem('current_page');

// Application startup

$(function(){ setTimeout(function(){ check_status(); document.getElementById('overlay').classList.add('remove'); }, 1000) });

function check_status(){
	
	// Close all pages
		document.getElementById('login-wrapper').classList.remove('active');
		document.getElementById('select-store-wrapper').classList.remove('active');
		document.getElementById('select_register_wrapper').classList.remove('active');
		document.getElementById('pos-wrapper').classList.remove('active');
	
	if( current_user && current_company  && current_store  && current_register ){
		
		document.getElementById('companyName').innerHTML = current_company.company_name;
		document.getElementById('storeName').innerHTML = current_store.name;
		document.getElementById('registerName').innerHTML = current_register.name;
		document.getElementById('employeeName').innerHTML = current_user.first_name + ' ' + current_user.last_name;
		
		loadRegister();
		document.getElementById('pos-wrapper').classList.add('active');
		
		if( current_register.status == 0 ){
			
			// Open the closed register
			document.getElementById('optionsPage').classList.add('active');
			openRegister();
			
		}else{
			showPage(current_page, 1);
			display_order();
		}
	}else{
		display_login();
	}
	
}

function loadRegister(){
	
	// Load saved order
	current_sale = orderModel.get_current_order();
	if( current_sale ){ display_order(); }
	
	// Load saved return
	current_return = returnModel.get_current_return();
	if( current_return ){ display_order(); }
	
	productModel.getProductsFromServer();
}

// Login

function display_login(){
	
	// There is no users, lets show the login page
	if( !current_user ){ 
		// There may be a company logged in, lets see
		if( current_company ){ document.getElementById('employee_company_id').value = current_company.id; }
		return document.getElementById('login-wrapper').classList.add('active'); 
	}
	if( !current_store ){ 
		display_stores_data();
		return document.getElementById('select-store-wrapper').classList.add('active'); 
	}
	if( !current_register ){
		display_register_data();
		return document.getElementById('select_register_wrapper').classList.add('active'); 
	}
}

function try_to_login(){
	
	postData = { 
		company_id: document.getElementById('employee_company_id').value,
		username: document.getElementById('employee_username').value,
		password: document.getElementById('employee_password').value 
	};
	
	$.post("/api4/try_to_login.json", postData, function(data) {
		console.log(JSON.stringify(data.stores));
           if ( data.status == 1 ){
			   current_user = data.user;
			   current_company = data.company;
			   all_stores = data.stores;
			   all_registers = data.registers;
			   save_meta_data();
           }else{
			   $('#login_wrapper>.notifi').html('The username or password is incorrect.')
			   $('#login_wrapper>.notifi').show();
           }
	}, 'json').error(function(){ alert('You must be connected to the internet to login.'); }).complete(function(){ check_status(); });
	
}

// Data Refresh

function reload(){
	$.post("/api4/reload_data.json", { api_token : current_company.api_token }, function(data){
		reload_data(data);
	}, 'json').error(function(){}).complete(function(){});
}

function reload_data(data){
	
	// Reload coupons
	dbCoupons.insert( data.coupons );
	localStorage.setItem( 'dbCoupons', JSON.stringify(data.coupons) );
	
}

// Save data

function save_meta_data(){
	localStorage.setItem( 'current_user', JSON.stringify(current_user) );
	localStorage.setItem( 'current_company', JSON.stringify(current_company) );
	localStorage.setItem( 'all_stores', JSON.stringify(all_stores) );
	localStorage.setItem( 'all_registers', JSON.stringify(all_registers) );
}

// Selecting Store

	function display_stores_data(){ aurora_worker.postMessage({'cmd': 'display_stores', 'store_data': all_stores}); }

	function selectStore(id){
		for( i=0; i<all_stores.length; i++ ){
			if( all_stores[i].id == id ){ 
				current_store = all_stores[i];
				localStorage.setItem('current_store', JSON.stringify(current_store));
				check_status(); 
			}
		}
	}
	
// Selecting Register
	
	function display_register_data(){ aurora_worker.postMessage({'cmd': 'display_registers', 'store_id': current_store.id, 'register_data': all_registers}); }
	
	function selectRegister(id){
		for( var i = 0; i < all_registers.length; i++ ){
			if( all_registers[i].id == id ){ 
				current_register = all_registers[i];
				localStorage.setItem('current_register', JSON.stringify(current_register));
				check_status(); 
			}
		}
	}
	
// Page Transitions
	
	function showPage(page, init){
		
		if( current_page == '' || current_page == null || current_page == 'null' ){ 

			current_page = 'cashRegisterPage'; 
			document.getElementById(current_page).classList.add('active');
			document.getElementById(current_page+'-right').classList.add('active');
			
			// Save New Page
			localStorage.setItem('current_page', current_page);
			
		}else{
			if( page != current_page || init == 1 ){
			
				// Transition Page
				document.getElementById(current_page).classList.remove('active');
				document.getElementById(current_page+'-right').classList.remove('active');
				document.getElementById(page).classList.add('active');
				document.getElementById(page+'-right').classList.add('active');
				
				// Save New Page
				current_page = page;
				localStorage.setItem('current_page', current_page);
				
				// Highlight the page
				var buttons = document.getElementsByClassName('topBarButton');
				for( i=0; i<buttons.length; i++ ){ buttons[i].classList.remove('active'); }
				if( current_page == 'cashRegisterPage' || current_page == 'returnsPage' || current_page == 'timesheetPage' || current_page == 'optionsPage'){
					document.getElementById(current_page+'Button').classList.add('active');
				}
				
			}
		}
		
		// Page specific
		if( current_page == 'cashRegisterPage' ){ resetScanBox(); }
		if( current_page == 'returnsPage' ){ returnPage(); }
		if( current_page == 'timesheetPage' ){ document.getElementById('timesheet-wrapper').classList.remove('active'); }
		
	}
	
	
	
	
	
	
	
// Cash Register
	
	function addItemToSale(id, qty){
		
		// Check if id was provided
		if( !id ){
			id = document.getElementById('scanField').value;
			qty = document.getElementById('qty').value;
		}
		
		// If we still dont have an id, click may have been accident
		if( !id ){ return false; }
		
		// Try to find the product
		product = productModel.findProductByIds( id );
		
		// If the product is not found, lets try a string search
		if( !product ){ return itemSearch( id.toString() ); }
		
		// If there is no sale make a new one
		if( !current_sale ){ current_sale = new saleModel(); }
		
		// Check and see if this item is already in the sale
		for (i=0;i<current_sale.order_line_items.length;i++){
			// Existing Product
			if (current_sale.order_line_items[i].product_id == product.id){
				current_sale.order_line_items[i].qty = parseInt(current_sale.order_line_items[i].qty)+parseInt(qty);
				current_sale.order_line_items[i].total = parseFloat( (current_sale.order_line_items[i].qty*product.price).toFixed(2)	); 
				current_sale.order_line_items[i].cost = parseFloat( (current_sale.order_line_items[i].qty*product.cost).toFixed(2) );
				current_sale.order_line_items[i].origional_total = parseFloat( (product.price*current_sale.order_line_items[i].qty).toFixed(2) );
				current_sale.order_line_items[i].net_profit = parseFloat( ((product.price-product.cost)*current_sale.order_line_items[i].qty).toFixed(2) );
				return totalOrder();
			}
		}
		
		// New Product
		var item = {
			name: product.name, 
			product_id: product.id, 
			price: product.price, 
			origional_price: product.price, 
			qty: parseInt(qty), 
			discount: 0,
			total: money(qty*product.price), 
			cost: money(qty*product.cost), 
			origional_total: money(product.price*qty), 
			sku: product.sku, 
			net_profit: money( (product.price-product.cost)*qty ), 
			nontax: product.nontax,
			appliedCoupon: 0
		};
		current_sale.order_line_items.push(item);
		return totalOrder();
		
	}
	
	function itemSearch(q){
		products = productModel.productSearch(q);
		if( products.length >= 1 ){
			item_html = '';
			for ( i=0; i<products.length; i++ ){
				item_html += '<tr><td><b>' + products[i].name + '</b></td><td><b>' + current_store.currency_code + parseFloat(products[i].price).toFixed(2) + '</b></td><td class="text-right"><input class="btn btn-success" value="Add Item" onclick="selectItem(\'' + products[i].id + '\', ' + $('#qty').val() + ')" /></td></tr>';
			}
			document.getElementById('item-search-items').innerHTML = item_html;
			document.getElementById('posArea').style.display = 'none';
			document.getElementById('itemSearch').style.display = 'block';
			resetScanBox();
		}else{
			alertCode('productNotFound', 'resetScanBox();');
		}
	}
	
	function selectItem(id, qty){
		addItemToSale(id, qty);
		hideItemSearch();
	}
	
	function hideItemSearch(){
		document.getElementById('posArea').style.display = 'block';
		document.getElementById('itemSearch').style.display = 'none';
		resetScanBox();
	}

	function totalOrder(){
		current_sale.subtotal = 0;
		current_sale.discount = 0;
		current_sale.net_profit = 0;
		current_sale.item_count = 0;
		taxable_value = 0;
		
		// Remove the item if the qty is 0
		for ( i=0; i<current_sale.order_line_items.length; i++ ){
			if( current_sale.order_line_items[i].qty == 0 ){
				current_sale.order_line_items.remove(current_sale.order_line_items[i]);
			}
		}
		
		// Loop through and total up order values
		for( i=0; i<current_sale.order_line_items.length; i++ ){
			current_sale.subtotal += current_sale.order_line_items[i].total;
			current_sale.discount += current_sale.order_line_items[i].discount;
			current_sale.net_profit += current_sale.order_line_items[i].net_profit;
			current_sale.item_count += current_sale.order_line_items[i].qty;
			if( current_sale.order_line_items[i].nontax != 1 ){
				taxable_value += money(current_sale.order_line_items[i].total);
			}
		}
		
		current_sale.tax = money( taxable_value*(current_store.tax_rate*0.01) );
		current_sale.tip = 0;
		current_sale.total = money(current_sale.subtotal) + money(current_sale.tax) + money(current_sale.tip);
		
		// Subtract the amount paid from the amount due
		current_sale.amount_due = money(current_sale.total);
		for( i=0;i<current_sale.order_payments.length;i++ ){
			current_sale.amount_due -= money(current_sale.order_payments[i].amount);
		}
		
		// If the order is blank, delete it
		if( current_sale.order_line_items.length == 0 && current_sale.order_payments.length == 0 && current_sale.customer_id == ''){
			return delete_sale( current_sale.id );
		}
		
		// Save and display order
		orderModel.saveCurrentOrder();
		display_order();
	}
	
	function display_order(){
		
		if( current_sale ){
			document.getElementById('no_order').style.display = 'none';
			document.getElementById('current_order').style.display = 'block';
		}else{
			document.getElementById('no_order').style.display = 'block';
			document.getElementById('current_order').style.display = 'none';
			return reset_register();
		}
		
		item_count_elements = document.getElementsByClassName('order-item_count');
		order_subtotal_elements = document.getElementsByClassName('order-subtotal');
		order_tax_elements = document.getElementsByClassName('order-tax');
		order_total_elements = document.getElementsByClassName('order-total');
		payment_remaining_elements = document.getElementsByClassName('payment-remaining-field');
		
		for( i=0; i<item_count_elements.length; i++){
			item_count_elements[i].innerHTML = current_sale.item_count;
		}
		for( i=0; i<order_subtotal_elements.length; i++){
			order_subtotal_elements[i].innerHTML = displayMoney(current_sale.subtotal);
		}
		for( i=0; i<order_tax_elements.length; i++){
			order_tax_elements[i].innerHTML = displayMoney(current_sale.tax);
		}
		for( i=0; i<order_total_elements.length; i++){
			order_total_elements[i].innerHTML = displayMoney(current_sale.total);
		}
		for( i=0; i<payment_remaining_elements.length; i++){
			payment_remaining_elements[i].value = current_sale.amount_due;
		}
		
		if( current_sale.amount_due <= 0.00 ){
			document.getElementById('RightPaymentButton').style.display = 'none';
			document.getElementById('RightCompleteButton').style.display = 'block';
			$('.due-title').html('CHANGE');
			$('.amount-due').html(displayMoney(current_sale.amount_due*-1).replace('-',''));
		}else{
			document.getElementById('RightPaymentButton').style.display = 'block';
			document.getElementById('RightCompleteButton').style.display = 'none';
			$('.due-title').html('DUE');
			$('.amount-due').html(displayMoney(current_sale.amount_due));
		}
		
		// Customer
		if( !current_sale.customer_name ){
			document.getElementById('customerNameBox').style.display = 'none';
			document.getElementById('customerSearchBox').style.display = 'block';
			document.getElementById('add-new-customer-btn').style.display = 'block';
		}else{
			document.getElementById('add-new-customer-btn').style.display = 'none';
			document.getElementById('customerNameBox').style.display = 'block';
			document.getElementById('customerNameBox').innerHTML = '<b>Name: </b>' + current_sale.customer_name;
			document.getElementById('customerSearchBox').style.display = 'none';
		}
		
		items = '';
		for ( n=0; n<current_sale.order_line_items.length; n++ ){
			if( current_sale.order_line_items[n].sku ){ sku = current_sale.order_line_items[n].sku; }else{ sku = ''; }
			items += "<tr><td><b>"+ current_sale.order_line_items[n].name +"</b></td><td class='hidden-sm'><b>"+ sku +"</b></td><td width='110' id='" + current_sale.order_line_items[n].product_id + "_price' ondblclick=\"lineItemEditable('price', '" + current_sale.order_line_items[n].product_id + "_price', '"+ current_sale.order_line_items[n].price +"')\"><b>"+ displayMoney(current_sale.order_line_items[n].price) +"</b></td><td style='width:125px;' ondblclick=\"lineItemEditable('qty', '" + current_sale.order_line_items[n].product_id + "_qty', '"+ current_sale.order_line_items[n].qty +"')\" id='" + current_sale.order_line_items[n].product_id + "_qty'><b>"+ current_sale.order_line_items[n].qty +"</b></td><td class='row'><b>"+ displayMoney(current_sale.order_line_items[n].total) +"</b></td><td class='row' width='95'><a class='btn btn-danger btn-line-item' onclick='addItemToSale(\""+ current_sale.order_line_items[n].product_id +"\", -1)' >Remove</a></td></tr>";
		}
		document.getElementById('register_line_items').innerHTML = items;
		setTimeout(function(){ resetScanBox(); }, 50);
	}
	
	function resetScanBox(){
		document.getElementById('qty').value = 1;
		document.getElementById('scanField').value = '';
		document.getElementById('scanField').focus();
	}
	
	function suspendSale(){
		current_sale.status = 'suspended';
		orderModel.saveCurrentOrder();
		current_sale = null;
		display_order();
	}
	
	function viewSuspendedSales(){
		suspended_sales = orderModel.suspendedSales();
		if( suspended_sales.length == 0 ){
			return alertCode('noSuspendedSales', 'resetScanBox()');
		}else{
			sales_html = '';
			for(i=0;i<suspended_sales.length;i++){
				line_items = '';
				for (n=0;n<suspended_sales[i].order_line_items.length;n++){line_items+="(" + suspended_sales[i].order_line_items[n].qty + ")" + suspended_sales[i].order_line_items[n].name + "<br>";}
				sales_html += "<tr><td class='row'>" + suspended_sales[i].created_at;
				sales_html += "/" + suspended_sales[i].created_at + "/" + suspended_sales[i].created_at + " at " + suspended_sales[i].created_at + " : " + suspended_sales[i].created_at + "</td><td class='row'>" + suspended_sales[i].customer_name + "</td><td class='row'>" + line_items + "</td><td class='row'><input type='button' value='Choose Sale' class='btn btn-go' onclick='selectSuspendedSale(\"" + suspended_sales[i].id + "\")'></td></tr>";
			}
			document.getElementById('suspendedSaleList').innerHTML = sales_html;
			showPage('suspendedScreen');
		}
	}

	function selectSuspendedSale(id){
		current_sale = orderModel.openSuspendedSale(id);
		totalOrder();
		showPage('cashRegisterPage');
	}
	
	function cancelSale(){
		for( i=0; i<current_sale.order_payments.length; i++ ){
			cancel_sale_refund(current_sale.order_payments[i].payment_type, current_sale.order_payments[i].amount, current_sale.order_payments[i].transaction_id, current_sale.id, 1);
		}
		
		delete_sale(current_sale.id);
	}
	
	function delete_sale(id){
		orderModel.delete_sale(id);
		current_sale = null;
		display_order();
	}
	
	function reset_register(){
		document.getElementById('register_line_items').innerHTML = '';
		resetScanBox();
	}

	// Editing line items
	
	function lineItemEditable(type, id, value){
		if (type=='qty'){
			document.getElementById(id).innerHTML = '<div class="input-group"><input type="text" class="form-control" placeholder="'+ value +'" id="' + id + '_field"><span class="input-group-btn"><button name="commit" type="submit" class="btn btn-go" onclick="inlineQtyChange(\'' + id.replace('_qty', '') + '\')">Save</button></span></div>';
		}
		if (type=='price'){
			document.getElementById(id).innerHTML = '<div class="input-group"><span class="input-group-addon">$</span><input type="text" class="form-control" placeholder="'+ money(value) +'" id="' + id + '_field"><span class="input-group-btn"><button name="commit" type="submit" class="btn btn-go" onclick="inlinePriceChange(\'' + id.replace('_price', '') + '\')">Save</button></span></div>';
			document.getElementById(id).style.width = '250px';
		}
		document.getElementById(id+'_field').focus();
	}

	function inlineQtyChange(id){
		changeItemQty(id, document.getElementById(id + '_qty_field').value);
	}

	function inlinePriceChange(id){
		changeItemPrice(id, document.getElementById(id + '_price_field').value);
		document.getElementById(id).style.width = 'auto';
		document.getElementById(id).innerHTML = displayMoney( document.getElementById( id + '_price_field').value) ;
	}

	function changeItemQty(id, qty){
		if(qty){
			for( i=0; i<current_sale.order_line_items.length; i++ ){
				if(current_sale.order_line_items[i].product_id == id){
					// Existing Product
					current_sale.order_line_items[i].qty = parseInt(qty);
					current_sale.order_line_items[i].total = parseFloat( (current_sale.order_line_items[i].qty*current_sale.order_line_items[i].price).toFixed(2) ); 
					current_sale.order_line_items[i].cost = parseFloat( (current_sale.order_line_items[i].qty*current_sale.order_line_items[i].cost).toFixed(2) );
					current_sale.order_line_items[i].origional_total = parseFloat( (current_sale.order_line_items[i].price*current_sale.order_line_items[i].qty).toFixed(2) );
					current_sale.order_line_items[i].net_profit = parseFloat( ((current_sale.order_line_items[i].price-current_sale.order_line_items[i].cost)*current_sale.order_line_items[i].qty).toFixed(2) );
				}
			}
		}
		return totalOrder();
	}

	function changeItemPrice(id, price){
		if(price){
			for(i=0;i<current_sale.order_line_items.length;i++){
				if(current_sale.order_line_items[i].product_id == id){
					// Existing Product
					current_sale.order_line_items[i].price = money(price);
					current_sale.order_line_items[i].total = parseFloat( (current_sale.order_line_items[i].qty*current_sale.order_line_items[i].price).toFixed(2) ); 
					current_sale.order_line_items[i].cost = parseFloat( (current_sale.order_line_items[i].qty*current_sale.order_line_items[i].cost).toFixed(2) );
					current_sale.order_line_items[i].net_profit = parseFloat( ((current_sale.order_line_items[i].price-current_sale.order_line_items[i].cost)*current_sale.order_line_items[i].qty).toFixed(2) );
				}
			}
		}
		return totalOrder();
	}
	
	// Coupons
	
	function addCoupon(){
		coupon = dbCoupons.find({where: {field: "code", compare: "equals", value: document.getElementById('couponId').value }})[0];
		
		if( coupon ){
			
			coupon_applied = 0;
			
			for (i=0;i<current_sale.order_line_items.length;i++){
				
				apply_coupon = 1;
				
				// Dont apply if coupon is single use and we already have multiple coupons.
				if( current_sale.order_line_items[i].appliedCoupon == 1 && coupon.multiple_coupons == 0 ){ apply_coupon = 0; }
				
				// Dont apply if minimum order price has not been met
				if( money(current_sale.subtotal) < money(coupon.minimum_order_price) ){ apply_coupon = 0; }
				
				// Check if there are required items, if so check if they exist
				if( coupon.required_items.length >= 1 ){
					
					if( coupon.required_items_type == 0 ){
						
						coupon_has_requred_items = 1;
						for( s=0; s<coupon.required_items.length; s++ ){
							item_in_cart = 0;
							for( n=1; current_sale.order_line_items.length; n++ ){
								if( coupon.required_items[s] == current_sale.order_line_items[n].product_id ){
									item_in_cart = 1;
								}
							}
							if( item_in_cart == 0 ){
								coupon_has_requred_items = 0;
							}
						}
						
					}else{
						
						coupon_has_all_requred_items = 0;
						for( s=0; s<coupon.required_items.length; s++ ){
							item_in_cart = 0;
							for( n=1; current_sale.order_line_items.length; n++ ){
								if( coupon.required_items[s] == current_sale.order_line_items[n].product_id ){
									item_in_cart = 1;
								}
							}
							if( item_in_cart == 1 ){
								coupon_has_requred_items = 1;
							}
						}
						
					}
					
					// After looping through "coupon_has_requred_items" must = 1
					if( coupon_has_requred_items == 0 ){
						apply_coupon = 0;
					}
					
				}
				
				// Check if coupon is valid for certain products only
				if( coupon.products.length >= 1 ){
					item_exist = 0;
					for ( p=0; p<coupon.products.length ;p++ ){
						if (coupon.products[p] == current_sale.order_line_items[i].product_id){
							item_exist = 1;
						}
					}
					if(item_exist == 0){
						apply_coupon = 0;
					}
				}
				
				// Make sure coupon has not been redeemed for sale already
				if( current_sale.coupon_ids.indexOf( coupon.id ) >= 0 ){ apply_coupon=0; }
				
				// Apply the coupon if its valid
				if( apply_coupon == 1 ){
					
					// Mark coupon applied
					coupon_applied = 1;
					
					// Calculate Discount
					if( coupon.discount_type == 0 ){
						new_price = current_sale.order_line_items[i].price - (current_sale.order_line_items[i].price*(coupon.discount_value/100));
					}else{
						new_price = current_sale.order_line_items[i].price - coupon.discount_value;
					}
					
					// Apply Coupon Pricing
					current_sale.order_line_items[i].price = new_price;
					current_sale.order_line_items[i].total = new_price*current_sale.order_line_items[i].qty;
					current_sale.order_line_items[i].appliedCoupon = 1;
					
				}
				
			}
			
			if( coupon_applied == 1 ){
				
				// mark the coupon as used
				current_sale.coupon_ids.push( coupon.id );
				
			}
			
			document.getElementById('couponId').value = '';
			return totalOrder();
			
		}
		
	}
	
	
	// Customer Section
	
	function showAddCustomer(){
		// Display The Modul
		document.getElementById('alertBoxBg').style.display = 'block';
		document.getElementById('new-customer').style.display = 'block';
		document.getElementById('content-modul').classList.add('active');
		// Focus the cursor
		setTimeout(function(){ document.getElementById('customer_first_name').focus(); },550);
	}
	
	function cancel_new_customer(){
		document.getElementById('content-modul').classList.remove('active');
		setTimeout(function(){ 
			document.getElementById('alertBoxBg').style.display = 'none';
			document.getElementById('new-customer').style.display = 'block';
			clearCustomerFields();
			setTimeout(function(){ resetScanBox(); }, 55);
		},600);
	}

	function findCustomer(){
		
		// If blank alert msg
		if( document.getElementById('customerSearch').value == '' ){
			return alertCode('enterCustomerPhone', 'resetScanBox()');
		}
		
		// Send search info to server
		$.post("/api4/find_customer.json", { api_token: current_company.api_token, q: document.getElementById('customerSearch').value }, function(data) {
			if (data.status == 1){
				addCustomerToOrder(data.customer_name, data.customer_id);
			}else{
				alertCode('customerNotFound', 'resetScanBox()');
			}
		}, 'json')
		.error(function() { alertCode('connectionError', 'resetScanBox()'); }).complete(function(){ document.getElementById('customerSearch').value = ''; });
	}

	function add_new_customer(){
		
		postData = {api_token: current_company.api_token, first_name: document.getElementById('customer_first_name').value, last_name: document.getElementById('customer_last_name').value, email: document.getElementById('customer_email').value, phone: document.getElementById('customer_phone').value, address: document.getElementById('customer_address').value, city: document.getElementById('customer_city').value, state: document.getElementById('customer_state').value, zip: document.getElementById('customer_zip').value }
		$.post("/api4/add_customer.json", postData, function(data) {
			if (data.status == 1){
				addCustomerToOrder(data.customer_name, data.customer_id);
			}else{
				alertCode('errorAddingCustomer', 'resetScanBox()');
			}
			cancel_new_customer();
		}, 'json')
		.error(function() { cancel_new_customer();alertCode('connectionError', 'resetScanBox()'); });
	}

	function addCustomerToOrder(customer_name, customer_id){
		current_sale.customer_id = customer_id;
		current_sale.customer_name = customer_name;
		$('#addCustomerBox').slideUp('fast', function() {});
		clearCustomerFields();
		orderModel.saveCurrentOrder();
		return display_order();
	}

	function clearCustomerFields(){
		document.getElementById('customer_first_name').value = '';
		document.getElementById('customer_last_name').value = '';
		document.getElementById('customer_email').value = '';
		document.getElementById('customer_phone').value = '';
		document.getElementById('customer_address').value = '';
		document.getElementById('customer_city').value = '';
		document.getElementById('customer_state').value = '';
		document.getElementById('customer_zip').value = '';
	}
	
	
	// Payment Screen ---> This has not been updated

	var currentPaymentType = 'cashPaymentBox', cashAmount = 0, checkAmount = 0;

	function paymentScreen(){
		$('.payment-remaining-field').val( money(current_sale.amount_due) );
		currentPaymentType = 'cashPaymentBox';
		setPaymentType('cashPaymentBox');
		showPage('paymentScreenPage');
	}
	

	function setPaymentType(type){ // <-- Updated
		
		if( type != currentPaymentType ){ 
			document.getElementById(currentPaymentType).style.display = 'none';
			document.getElementById(type).style.display = 'block';
		}
		// Type Specific Commands
		if(type == "creditCardPaymentBox"){ 
			scanCreditCard();
		}
		if( type == "giftCardPaymentBox" ){ document.getElementById('giftMagData').focus(); }
		if( type == "cashPaymentBox" ){ cashAmount = 0; }
		// Update current type
		currentPaymentType = type;

	}

	function manualCard(){
		$("#manualCCField").show();
		$("#scanCCField").hide();
	}

	function scanCreditCard(){
		$("#manualCCField").hide();
		$("#scanCCField").show();
		document.getElementById('magData').focus();
	}

	function addPayment(payment_type){
		// Generate a payment ID
		payment_id = current_sale.id + "P" + current_sale.order_payments.length;
		if (payment_type == 'cash'){ return addCashPayment(payment_id); }
		if (payment_type == 'credit_card'){ return addCreditCardPayment(payment_id); }
		if (payment_type == 'check'){ return addCheckPayment(payment_id); }
		if (payment_type == 'gift_card'){ return addGiftCardPayment(payment_id); }
	}

	function addCashPayment(payment_id){
		current_sale.order_payments.push({id: payment_id, amount: money( document.getElementById('amountField').value ), payment_type: "cash", transaction_id: payment_id, authorization_id: ""})
		adjustTill( document.getElementById('amountField').value );
		exitPaymentScreen();
	}

	function addCheckPayment(payment_id){
		current_sale.order_payments.push({id: payment_id, amount: parseFloat( document.getElementById('amountFieldCheck').value ).toFixed(2), payment_type: "check", transaction_id: payment_id, authorization_id: ""})
		exitPaymentScreen();
	}

	function addCreditCardPayment(payment_id){
		// If integrated
		ProcessingAlert('processingPayment');
		MagData = document.getElementById('magData').value;
		if(MagData){
			amount = money( document.getElementById('amountFieldCC').value ).toFixed(2);
		}else{
			amount = money( document.getElementById('amountFieldCCManual').value ).toFixed(2);
		}
		// Card Details
		CardNum = $('#creditCardNumber').val();
		ExpDate = $('#cardExpDate').val();
		NameOnCard = $('#cardHolderName').val();
		cv2 = $('#CardCvvNumber').val();
	
		// Check if non integrated
		if (globalGateway === 'OfflineCreditCard'){
			current_sale.order_payments.push({id: payment_id, amount: parseFloat(amount).toFixed(2), payment_type: "credit_card", transaction_id: data.transid, authorization_id: data.authcode, card_last_four: data.card_last_four, exp_date: data.exp_date});
			clearAlert(null);
			return exitPaymentScreen();
		}
	
		// Post Data
		postData = {api_token: current_company.api_token, magdata: MagData.toString(), orderId: current_sale.id.toString(), card_number: CardNum.toString(), exp: ExpDate.toString(), cvv: cv2.toString(), name: NameOnCard.toString(), payment_amount: amount.toString(), store_id: current_store.id, register_id: current_register.id};
		$.post("/payment_api_base/credit_card_payment.json", postData, function(data) {
			if (data.status == 1){
				current_sale.order_payments.push({id: payment_id, amount: parseFloat(amount).toFixed(2), payment_type: "credit_card", transaction_id: data.transaction_id, card_last_four: data.card_last_four });
			}else{
				alert("I'm sorry, I could not process this card \n \nReason:\n" + data.msg)
			}
		}, 'json')
		.error(function() {
			if (navigator.onLine){
				alert("I am having a problem connecting to the payment server. Wait a second then try again.");
			}else{
				alert("I'm sorry, It appears the internet connection is down. I can only process credit cards when I am online.");
			}
		})
		.complete(function() {
			clearAlert(null);
			exitPaymentScreen();
		});
	}

	function addGiftCardPayment(payment_id){
		CardNum = $('#giftMagData').val();
		charge_amount = money($('#amountFieldGC').val()).toFixed(2)
		postData = {api_token: current_company.api_token, card_number: CardNum.toString(), amount: charge_amount, order_id: current_sale.id, id: payment_id, store_id: current_store.id};
		$.post("/payment_api_base/gift_card_payment.json", postData, function(data) {
			if (data.status == 'Approved'){	
				current_sale.order_payments.push({id: payment_id, amount: parseFloat(data.charged_amount).toFixed(2), payment_type: "gift_card", exp_date: data.exp_date, remaining_balance: parseFloat(data.remaining_balance).toFixed(2), transaction_id: data.transaction_id, gift_card_id : data.gift_card_id})
				saveOrder();
			}else{
				alert("I'm sorry, I could not process this card.")
			}
		}, 'json')
		.error(function() {
			if (navigator.onLine){
				alert("I am having a problem connecting to the payment server. Wait a second then try again.");
			}else{
				alert("I'm sorry, It appears the internet connection is down. I can only process credit cards when I am online.");
			}
		})
		.complete(function() {
			exitPaymentScreen();
		});
	}

	function addCashAmmount(amount){
		cashAmount+=money(amount)
		$('#amountField').val(cashAmount.toFixed(2));
	}

	function addCheckAmmount(amount){
		checkAmount+=parseFloat(amount)
		$('#amountFieldCheck').val(checkAmount.toFixed(2));
	}

	function exitPaymentScreen(){
		showPage('cashRegisterPage');
		$("#cashPaymentBox").show();
		$("#creditCardPaymentBox").hide();
		$("#giftCardPaymentBox").hide();
		$("#checkPaymentBox").hide();	
		$('.payment-data-field').val('');
		cashAmount = null;
		totalOrder();
	}
	
	function adjustTill(amount){
		new_till = money( money(localStorage.getItem("till")) + money(amount) );
		localStorage.setItem( "till", new_till );
		
		for (i=0;i<all_registers.length;i++){
			if(all_registers[i].id == current_register.id){
				all_registers[i].till = new_till
			}
		}
		localStorage.setItem('all_registers', JSON.stringify(all_registers));
	}
	
	function cancel_sale_refund(type, amount, transaction_id, order_id, void_trans){
		
		if( type == 'credit_card' ){
			postData = {api_token: current_company.api_token, transaction_id: transaction_id, amount: amount, order_id: order_id, void_trans: void_trans};
			$.post("/payment_api_base/credit_card_refund.json", postData, function(data) {
				if (data.status == 1){	
					
				}else{
					alert("I'm sorry, I could not refund this card.")
				}
			}, 'json').error(function() {}).complete(function() {});
		}
		
	}
	
	function completeSale(){
		line_items = '', subtotal = 0, credit_card = 0, gift_card = 0, check = 0, cash = 0.00;change=0;
		for (i=0;i<current_sale.order_line_items.length;i++){
			line_items += '<tr><td>( ' + current_sale.order_line_items[i].qty + ' ) ' + current_sale.order_line_items[i].name + '</td><td>' + current_store.currency_code + parseFloat(current_sale.order_line_items[i].price).toFixed(2) + '</td><td>' + current_store.currency_code + parseFloat(current_sale.order_line_items[i].total).toFixed(2) + '</td></tr>';
		}
		for (i=0;i<current_sale.order_payments.length;i++){
			if (current_sale.order_payments[i].payment_type == 'cash'){
				cash += parseFloat(current_sale.order_payments[i].amount);
			}
			if (current_sale.order_payments[i].payment_type == 'credit_card'){
				credit_card += parseFloat(current_sale.order_payments[i].amount);
			}
			if (current_sale.order_payments[i].payment_type == 'gift_card'){
				gift_card += parseFloat(current_sale.order_payments[i].amount);
			}
			if (current_sale.order_payments[i].payment_type == 'check'){
				check += parseFloat(current_sale.order_payments[i].amount);
			}
		}
		if(money(current_sale.amount_due)<= -0.01){
			payment_id = (current_sale.id + "P" + current_sale.order_payments.length).toString();
			current_sale.order_payments.push({id: payment_id, amount: money(current_sale.amount_due).toFixed(2), payment_type: "change", transaction_id: payment_id, authorization_id: ""})
			adjustTill(current_sale.amount_due);
		}
		orderModel.saveCurrentOrder();
		$('#innerReceiptProductList').html(line_items);
		$('.receiptSubTotal').html(current_store.currency_code + money(subtotal).toFixed(2));
		$('.receiptTax').html(current_sale.tax.toFixed(2));
		$('.receiptTotal').html(current_sale.total.toFixed(2));
	
		$('.receiptCash').html(current_store.currency_code + money(cash).toFixed(2));
		$('.receiptCreditCard').html(current_store.currency_code + money(credit_card).toFixed(2));
		$('.receiptGiftCard').html(current_store.currency_code + money(gift_card).toFixed(2));
		$('.receiptCheck').html(current_store.currency_code + money(check).toFixed(2));
		$('.receiptChange').html(current_store.currency_code + money(current_sale.amount_due).toFixed(2).replace('-', ''));
	
		$('.companyName').html(current_company.company_name);
		$('.storeAddress').html(current_store.address );
		$('#barcode').html( code128( current_sale.id.toString() ) );
		$('#receiptBarCodeId').html(current_sale.id.toString());

		showPage('receiptScreenPage');
		setTimeout(function(){window.print();}, 200);
		syncOrder(current_sale.id);
		current_sale=null;
		display_order();
	}
	
	function syncOrder(order_id){
		order = JSON.stringify(dbOrders.find({where: {field: '_id', compare: 'equals', value: order_id}})[0]);
		$.post("/api4/sync_order.json", {api_token: current_company.api_token, orderData: order}, function(data) {
			if (data.status == 1){
				dbOrders.remove({where: {field: "_id", compare: "equals", value: order_id}});
			}else{
				dbOrders.update({data: {status: 'completedoffline'}, where: {field: '_id', compare: 'equals', value: order_id}});
			}
		}, 'text')
		.error(function() {
			dbOrders.update({data: {status: 'completedoffline'}, where: {field: '_id', compare: 'equals', value: order_id}});
		})
		.complete(function(){localStorage.setItem('dbOrders', JSON.stringify(dbOrders.find()));});
	}



// Models
	
	function getProductsFromServer(){
		postData = { api_token: current_company.api_token, status: "load"};
		$.post("/api3/loadProducts.json", postData, function(data) {
			insertProducts(data.items);
		}, 'json')
		.error(function() { 
			insertProducts(JSON.parse(localStorage.getItem('dbProducts')));
		}).complete(function(){

		});
	}
	
	// Product Models
	productModel = {
		
		getProductsFromServer: function(){
			$.post("/api4/load_products.json", { api_token: current_company.api_token}, function(data) { productModel.insertProducts(data); }, 'json').error(function() { productModel.insertProducts(JSON.parse(localStorage.getItem('dbProducts'))); });
		},
		
		insertProducts: function(data){
			dbProducts.clear();
			dbProducts.insert(data);
			this.save();
		},
		
		findProductByIds: function(q){
			q = q.toString();
			query = {where: {join: "or", terms: [{field: "pid", compare: "equals", value: q},{field: "upc", compare: "equals", value: q},{field: "sku", compare: "equals", value: q},{field: "ean", compare: "equals", value: q},{field: "m_sku", compare: "equals", value: q}]}};
			return dbProducts.find(query)[0];
		},
		
		productSearch: function(q){
			return dbProducts.find({where: {field: "tags", compare: "contains", value: q.toLowerCase() }});
		},
		
		all: function(){
			return dbProducts.find();
		},
		
		save: function(){
			dbProducts.commit();
			localStorage.setItem( "dbProducts", JSON.stringify(dbProducts.find()) );
		}
		
	}
	
	
	
	
	
// Helpers
	
	function getTimeString(utc){
		var date = new Date();
		var year = date.getUTCFullYear();
		var month = date.getMonth() + 1;
		if (month < 10){
			var month = "0"+month;
		}
		var day = date.getDate();
		if (day < 10){
			var day = "0"+day;
		}
		var hour = date.getHours();
		if (hour < 10){
			var hour = "0"+hour;
		}
		var min = date.getMinutes();
		if (min < 10){
			var min = "0"+min;
		}
		var sec = date.getSeconds();
		if (sec < 10){
			var sec = "0"+sec;
		}
		if (utc == 'yes'){
			return Date.UTC(year.toString(), month.toString(), day.toString(), hour.toString(), min.toString(), sec.toString());
		}else{
			return year.toString()+month.toString()+day.toString()+hour.toString()+min.toString()+sec.toString();
		}
	}
	
	function get_utc_time(){
		return new Date()*1;
	}
	
	function money(num){
		number = parseFloat(Number(num).toFixed(2));
		return number;
	}
	
	function displayMoney(num){
		number = parseFloat(Number(num)).toFixed(2);
		dollars = number.split(".")[0].split("").reverse().join("");
		count = (dollars.length/3).toFixed(0);
		format = '';
		for(i=0;i<=count;i++){
			format += dollars.split("",3).join("");
			dollars = dollars.substr(3);
			if(dollars){
				format+=','
			}
		}
		return (current_store.currency_code+format.split("").reverse().join("")+'.'+number.split('.')[1]).toString();
	}
	
	
	
	//
	// Options
	//
	
	function logOffStore(){
		
		// Clear the variables
		current_store = null;
		
		// Clear the storage data
		localStorage.removeItem('current_store');
		
		// If we logged off the store, we need to log out of the register as well.
		logOffRegister();
		
	}
	
	function logOffRegister(){
		
		// Clear the variables
		current_register = null;
		
		// Clear the storage data
		localStorage.removeItem('current_register');
		
		// Reset the POS
		check_status();
		
	}
	
	function logOffEmployee(){
		
		// Clear the variables
		current_user = null;
		
		// Clear the storage data
		localStorage.removeItem('current_user');
		
		// Tell the database
		//$.post("/api4/logOffEmployee.json", {api_token: current_company.api_token, register_id: current_register.id}, function(data){}, 'json');
		
		// Reset the POS
		check_status();
		
	}
	
	// Verify Till >> 0 = audit, 1 = close, 2 = open
	var tillVerify = 0;
	function auditTill(){
		tillVerify = 0;
		updateVerifyTill();
	}

	function closeRegister(){
		tillVerify = 1;
		updateVerifyTill();
	}
	
	function openRegister(){
		showPage('optionsPage');
		tillVerify = 2;
		updateVerifyTill();
	}

	function updateVerifyTill(){
		
		// Show the till form
			document.getElementById('optionsWrapper').style.display = 'none';
			document.getElementById('auditTillWrapper').style.display = 'block';
		
		// Set the blurs and cous
			
			$("#auditTillWrapper input").focus(function () {
				if ($(this).val() == '0'){
					$(this).val('');
				}
			});
			
			$("#auditTillWrapper input").blur(function () {
				if ($(this).val() == ''){
					$(this).val('0');
				}
			});
		
		// Total Up
			
			$("#auditTillWrapper input").keyup(function(){
				verifytotal = 0;
				// Loose Change
				verifytotal += parseFloat(document.getElementById('qty_item_a').value)*0.01 || 0; // pennies
				verifytotal += parseFloat(document.getElementById('qty_item_b').value)*0.05 || 0; // nickels
				verifytotal += parseFloat(document.getElementById('qty_item_c').value)*0.10 || 0; // dimes
				verifytotal += parseFloat(document.getElementById('qty_item_d').value)*0.25 || 0; // quarters
				// Change Rolls
				verifytotal += parseFloat(document.getElementById('qty_item_ar').value)*0.50 || 0; // penny rolls
				verifytotal += parseInt(document.getElementById('qty_item_br').value)*1.00 || 0; // nickel rolls
				verifytotal += parseInt(document.getElementById('qty_item_cr').value)*5.00 || 0; // dime rolls
				verifytotal += parseInt(document.getElementById('qty_item_dr').value)*10.00 || 0; // quarter rolls
				// Dolalrs
				verifytotal += parseInt(document.getElementById('qty_item_1').value)*1.00 || 0; // ones
				verifytotal += parseInt(document.getElementById('qty_item_2').value)*5.00 || 0; // Fives
				verifytotal += parseInt(document.getElementById('qty_item_3').value)*10.00 || 0; // Tens
				verifytotal += parseInt(document.getElementById('qty_item_4').value)*20.00 || 0; // Twenties
				verifytotal += parseInt(document.getElementById('qty_item_5').value)*50.00 || 0; // Fifties
				verifytotal += parseInt(document.getElementById('qty_item_6').value)*100.00 || 0; // Hundreds
				document.getElementById('verify_till_amount').value = verifytotal.toFixed(2);
			});
	}

	
	
	function submit_till_verification(){
		
		var till_amount = money( document.getElementById('verify_till_amount').value );
		
		var postData = { 
			api_token: current_company.api_token, 
			id: 'ver' + new Date().getTime() + 'reg' + current_register.id, 
			register_id: current_register.id, 
			employee_id: current_user.id, 
			employee_name: current_user.first_name + " " + current_user.last_name, 
			amount: till_amount, 
			verificationMethod: tillVerify, 
			timestamp: new Date().getTime()
		};
		
		$.post("/api4/submit_till_verification.json", postData, function(data){
			
			// Set new till
			localStorage.setItem('till', data.new_till);
			
		}, 'json').error(function() {}).complete(function(){
			
			// reset the view
			document.getElementById('optionsWrapper').style.display='block';
			document.getElementById('auditTillWrapper').style.display='none';
				
			// If we are closing the register
			if( tillVerify == 1 ){
				
				// Set the register settings
				current_register.current_employee = '';
				current_register.current_employee_id = '';
				current_register.status = 0;
				current_register.till = 0;
				
				// Set the register status to 0 for closed
				for (var i = 0; i < all_registers.length; i++ ){
					if( all_registers[i].id == current_register.id ){ all_registers[i] = current_register; }
				}
				localStorage.setItem('all_registers', JSON.stringify(all_registers));
				
				// Log out of the register
				logOffRegister();
		
			}
				
			// If we are opening the register
			if( tillVerify == 2 ){
				
				// Set the register settings
				current_register.current_employee = current_user.first_name + ' ' + current_user.last_name;
				current_register.current_employee_id = current_user.id;
				current_register.status = 1;
				current_register.till = till_amount;
				
				// Update DB
				for (var i = 0; i < all_registers.length; i++ ){
					if( all_registers[i].id == current_register.id ){ all_registers[i] = current_register; }
				}
				
				// Update Local Storage
				localStorage.setItem('current_register', JSON.stringify(current_register));
				localStorage.setItem('till', till_amount );
				
				// Show register page
				showPage('cashRegisterPage');
				
			}
				
			// Reset the form fields
			document.getElementById('verify_till_amount').value = '';
			document.getElementById('qty_item_a').value = 0;  
			document.getElementById('qty_item_b').value = 0;  
			document.getElementById('qty_item_c').value = 0;  
			document.getElementById('qty_item_d').value = 0;  
			document.getElementById('qty_item_ar').value = 0;  
			document.getElementById('qty_item_br').value = 0;  
			document.getElementById('qty_item_cr').value = 0;  
			document.getElementById('qty_item_dr').value = 0;  
			document.getElementById('qty_item_1').value = 0;  
			document.getElementById('qty_item_2').value = 0;  
			document.getElementById('qty_item_3').value = 0;  
			document.getElementById('qty_item_4').value = 0;  
			document.getElementById('qty_item_5').value = 0;  
			document.getElementById('qty_item_6').value = 0;
				
		});
		
	}
	
	function add_cash_to_register(){
		
		var amount = money(document.getElementById('addition_amount').value);
		
		// Only post if the amount is greater than 1 penny
		if( amount >= 0.01 ){
			
			utc_time = new Date()*1;
			
			postData = { api_token: current_company.api_token, id: 'add' + utc_time + 'reg' + current_register.id, register_id: current_register.id, timestamp: utc_time, employee_id: current_user.id, employee_name: current_user.first_name + ' ' + current_user.last_name, amount: amount };
		
			$.post("/api4/add_cash_to_register.json", postData, function(data) {
			
				// Save for later upload if failes
				if( data.status != 1 ){ dbTills.insert([ {till_type: 'add', time: getTimeString('no').toString(), register_id: globalRegisterId, employee_id: globalEmployeeId, employee_name: globalEmployeeName, amount: amount} ]); }
		
			}, 'json').complete(function(){
			
				// Add the amount to the till
				adjustTill( amount );
			
				// Alert the user the amount has been added
				alert('Added ' + displayMoney(amount) + ' to the till.');
			
				// Clear the input field
				document.getElementById('addition_amount').value = '';
			
			});
			
		}else{
			
			// Let the user know he needs to enter an amount
			alert('Please enter an amount to add to the till');
			
		}	

	}

	function remove_cash_from_register(){
		
		var amount = money(document.getElementById('withdraw_amount').value);
		
		// Only post if the amount is greater than 1 penny
		if( amount >= 0.01 ){
			
			utc_time = new Date()*1;
			
			postData = { api_token: current_company.api_token, id: 'sub' + utc_time + 'reg' + current_register.id, register_id: current_register.id, timestamp: utc_time, employee_id: current_user.id, employee_name: current_user.first_name + ' ' + current_user.last_name, amount: amount };
		
			$.post("/api4/remove_cash_from_register.json", postData, function(data) {
			
				// Save for later upload if failes
				if( data.status != 1 ){ dbTills.insert([ { till_type: 'add', time: getTimeString('no').toString(), register_id: globalRegisterId, employee_id: globalEmployeeId, employee_name: globalEmployeeName, amount: amount } ]); }
		
			}, 'json').complete(function(){
			
				// Remove the amount from the till
				adjustTill( money(amount*-1.00) );
			
				// Alert the user the amount has been removed
				alert('Removed ' + displayMoney( amount ) + ' to the till.');
			
				// Clear the input field
				document.getElementById('withdraw_amount').value = '';
			
			});
			
		}else{
			
			// Let the user know he needs to enter an amount
			alert('Please enter an amount to remove from the till');
			
		}

	}
	
	
	
	
	
	//
	// Timesheet
	//
	
	function punch_timesheet(){
		
		// Set username and password
		var username = document.getElementById('timeclockUsername').value;
		var password = document.getElementById('timeclockPassword').value;
		
		// Make sure username and password are not blank
		if( username == '' || password =='' ){
			alert('Please enter your username and password');
		}
		
		// Configure the post data
		var postData = { api_token: current_company.api_token, time: new Date()*1, store_id: current_store.id, username: username, password: password };
		
		// Push to server
		$.post("/api4/punch_clock.json", postData, function(data) {
			if ( data.status == 1 ){
				document.getElementById('timeclock-result-header').innerHTML = data.employee_name;
				document.getElementById('timeclock-result-text').innerHTML = 'You have been successfully <b>Clocked ' + data.clock + '</b>';
				document.getElementById('timesheet-wrapper').classList.add('active');	
			}else{
				document.getElementById('timeclock-result-header').innerHTML = 'Sorry...';
				document.getElementById('timeclock-result-text').innerHTML = 'You have not been clocked in. Check your username and password and try again';
				document.getElementById('timesheet-wrapper').classList.remove('active');
			}
		}, 'json').error(function(){
			save_offline( postData, 'timesheet' );
		});
		
		// Clear elements
		document.getElementById('timeclockUsername').value = '';
		document.getElementById('timeclockPassword').value = '';
		
	}

	
	
//= require aurora_orders
//= require aurora_barcode
	
	
	
