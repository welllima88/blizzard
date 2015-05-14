//
// Order Returns Module
//
	
	// Global Variable
	var current_return = null;
	var original_sale = null;
	
	// Model
	
	function newReturnModel() {
	
		timestring = new Date()*1;	
		this._id = 'RT' + current_register.id + timestring, 
		this.status = 'open', 
		this.created_at = timestring, 
		this.completed_at = null, 
		this.customer_name = null,
		this.customer_id = null,
		
		this.item_count = 0,
		this.subtotal = 0.00,
		this.tax_rate = parseFloat(current_store.tax_rate*0.01),
		this.tax = 0.00,
		this.total = 0.00,
		this.amount_owed = 0.00,
		this.tax_refunded = 0.00,
		this.total_refunded = 0.00,
		
		this.purchased_items = [],
		this.order_payments = [],
		this.order_return_line_items = [],
		this.order_return_payments = [],
		
		this.store_id = current_store.id,
		this.store_name = current_store.name,
		this.register_id = current_register.id,
		this.register_name = current_register.name,
		
		this.order_id = null,
		this.employee_id = current_user.id,
		this.employee_name = current_user.first_name + ' ' + current_user.last_name
	
	}
	
	returnModel = {
	
		saveCurrentReturn: function(){
			if( dbOrderReturns.find({where: {field: "_id", compare: "equals", value: current_return._id}})[0] != null ){
				dbOrderReturns.update({data: current_return, where:{field: "_id", compare: "equals", value: current_return._id}});
			}else{
				dbOrderReturns.insert([current_return]);
			}
			this.save();
		},
	
		save: function(){
			localStorage.setItem( 'dbOrderReturns', JSON.stringify(dbOrderReturns.find()) );
		},
	
		get_current_return: function(){
			return dbOrderReturns.find({where: {field: "status", compare: "equals", value: "open"}})[0];
		},
		
		get_return: function(id){
			return dbOrderReturns.find({where: {field: "_id", compare: "equals", value: id}})[0];
		},
	
		delete_return: function(id){
			dbOrderReturns.remove({where: {field: "_id", compare: "equals", value: id}});
			this.save();
		}
	
	}
	
	
	// 
	
	
	// Views and Displays
	
	
		function returnPage(){
			
			if( current_return ){
				document.getElementById('no_return').style.display = 'none';
				document.getElementById('current_return').style.display = 'block';
				displayOrderReturn();
			}else{
				document.getElementById('no_return').style.display = 'block';
				document.getElementById('current_return').style.display = 'none';
				document.getElementById('origionalLineItems').innerHTML = '';
				document.getElementById('return_line_items').innerHTML = '';
				document.getElementById('return_item_count').innerHTML = '0';
				document.getElementById('returnSubtotal').innerHTML = '0.00';
				document.getElementById('returnTax').innerHTML = '0.00';
				document.getElementById('returnTotal').innerHTML = '0.00';
				document.getElementById('returnDue').innerHTML = '0.00';
				returnFocusCheck();
			}
			
		}
	
		function returnFocusCheck(){
			document.getElementById('returnScanField').value='';
			document.getElementById('returnScanField').focus();
			document.getElementById('returnQty').value = 1;
		}
	
		function displayOrderReturn(){
			
			// If the return is non existant, reset register
			if( !current_return ){ return returnPage(); }
			
			// Display the return items
			var return_items = '<tr style="background-color:#eeeeee;"><td class="line_heading"><strong>PRODUCT NAME:</strong></td><td class="line_heading" width="110"><strong>PRICE:</strong></td><td class="line_heading" width="95">&nbsp;</td></tr>';
			
			for( var i=0;i<current_return.order_return_line_items.length;i++){
				return_items += "<tr><td class='row'><strong>"+ current_return.order_return_line_items[i].name +"</strong></td><td class='row' width='110'><strong>$"+ parseFloat(current_return.order_return_line_items[i].price).toFixed(2) +"</strong></td><td class='row' width='95'><a class='btn btn-danger' onClick='removeReturnItem(\"" + current_return._id + "\", \""+ current_return.order_return_line_items[i].product_id +"\" )' >Remove</a></td></tr>";
			}
			document.getElementById('return_line_items').innerHTML = return_items;
			
			// Display the pricing
			$('.return-item-count').html( current_return.item_count );
			$('.return-subtotal').html( displayMoney(current_return.subtotal) );
			$('.return-tax').html( displayMoney(current_return.tax) );
			$('.return-total').html( displayMoney(current_return.total) );
			$('.return-due').html( displayMoney(current_return.amount_owed) );
			//document.getElementById('returnPaymentRightAmount').innerHTML = displayMoney(current_return.amount_owed);
			document.getElementById('returnAmountField').value = displayMoney(current_return.amount_owed);
			$('.return-remaining').val( money(current_return.amount_owed) );
			
			if( current_return.order_id ){
				$('.origionalLineItemsWrapper').show();
				displayOrderedItems();
			}else{
				$('.origionalLineItemsWrapper').hide();
			}
			if ( current_return.order_return_payments.length >= 1 ){
				document.getElementById('cancelReturnButton').style.display = 'none';
			}else{
				document.getElementById('cancelReturnButton').style.display = 'inline-block';
			}
			if( current_return.amount_owed.toFixed(2) === '0.00' ){
				document.getElementById('RightReturnPaymentButton').style.display = 'none';
				document.getElementById('RightReturnCompleteButton').style.display = 'block';
			}else{
				document.getElementById('RightReturnPaymentButton').style.display = 'block';
				document.getElementById('RightReturnCompleteButton').style.display = 'none';
			}
			
			// If there is a origional sale show it
			if( original_sale ){ document.getElementById('return_items_wrapper').classList.add('original_sale'); }
			
			// Focus
			returnFocusCheck();
			
		}
		
		function displayOrderedItems(){
			var line_items_html = '<tr class="headingOLI"><td>Product</td><td>Price</td><td>QTY</td><td></td></tr>';
			for( var i=0;i<current_return.purchased_items.length;i++ ){
				line_items_html += '<tr><td>' + current_return.purchased_items[i].name + '</td><td>' + displayMoney(current_return.purchased_items[i].price) + '</td><td>' + current_return.purchased_items[i].qty + '</td><td><input type="button" value="+ Add" class="btn btn-success btn-sm" onclick="addItemToReturn(\'' + current_return.purchased_items[i].product_id + '\', \'1\', \'' + current_return.purchased_items[i].price + '\')"></td></tr>';
			}
			$('.origionalLineItems').html(line_items_html);
		}
		
	
	
	// Actions
	
		function addToReturn(query, qty){
			
			// If we did not pass a value, lets pull from the input
			if( !query ){ 
				query = document.getElementById('returnScanField').value; 
				qty = document.getElementById('returnQty').value; 
			}
			
			// If we still dont have a query param, it may be blank
			if(!query){
				returnFocusCheck();
				return false;
			}
			
			// Get The item
			result = dbProducts.find({where: {join: "or", terms: [{field: "pid", compare: "equals", value: query.toString()},{field: "upc", compare: "equals", value: query.toString()},{field: "sku", compare: "equals", value: query.toString()},{field: "ean", compare: "equals", value: query.toString()},{field: "m_sku", compare: "equals", value: query.toString()}]} })[0];
			
			// if the result exist lets add it to the return
			if( result ){
				addItemToReturn( result.id, qty );
			}else{
				// If there is no result check if this is a sale ID
				if(query.slice(-1) == 'R'){
					returnGetOrder( query );
				}else{
					returnFocusCheck();
					return alert('Product/Order Not Found')
				}
			}
			
		}
		
		
		function addItemToReturn(product_id, qty){
			// Get the item from the DB
			var product_data = dbProducts.find({where: {field: "pid", compare: "equals", value: product_id}})[0];
			
			// If we dont have an open return, lets create one
			if( !current_return ){ current_return = new newReturnModel(); }
			
			// If there was a receipt check and see the receipt price
			var origional_product_data = null;
			if( original_sale ){
				for( var i=0; i<current_return.purchased_items.length; i++ ){
					if( current_return.purchased_items[i].product_id == product_id ){
						origional_product_data = current_return.purchased_items[i];
					};
				}
			}
			
			// See how many we have currently in the return
			var current_qty = 0;
			for( var n = 0; n<current_return.order_return_line_items.length; n++ ){
				if( current_return.order_return_line_items[n].product_id == product_data.pid ){
					current_qty++;
				}
			}
			
			// For each QTY we are returning add as a seperate line item
			for( n=0;n<parseInt(qty); n++ ){
				
				// Set the correct pricing
				if( origional_product_data && current_qty < origional_product_data.qty ){
					return_price = parseFloat(origional_product_data.price);
				}else{
					return_price = parseFloat(product_data.return_price);
				}
				
				// Add data to return
				current_return.order_return_line_items.push({
					id: parseInt(current_return.order_return_line_items.length)+parseInt(1), 
					name: product_data.name, 
					product_id: product_data.pid, 
					price: return_price, 
					nontax: product_data.nontax
				});
				
				// Update the qty in the return
				current_qty++;
			
			}
			
			// Show data on sreen
			totalReturn();
			returnPage();

		}
		
		function totalReturn(){
			var rsubtotal=0.00;rtax=0.00;
			for( var i=0;i<current_return.order_return_line_items.length;i++){
				rsubtotal+=money(current_return.order_return_line_items[i].price);
				if(current_return.order_return_line_items[i].nontax != 1){
					rtax+=money(current_return.order_return_line_items[i].price)*current_return.tax_rate;
				}
			}
			current_return.item_count = current_return.order_return_line_items.length;
			current_return.subtotal = rsubtotal;
			current_return.tax = rtax;
			current_return.total = money(rsubtotal)+money(rtax);
			var amount_owed=current_return.total;var tax_refunded=0.00;var total_refunded=0.00;
			for( var i=0;i<current_return.order_return_payments.length;i++){
				amount_owed-=money(current_return.order_return_payments[i].amount);
				tax_refunded+=money(current_return.order_return_payments[i].amount*current_return.tax_rate);
				total_refunded+=money(current_return.order_return_payments[i].amount);
			}
			current_return.amount_owed=money(amount_owed);
			current_return.tax_refunded=money(tax_refunded);
			current_return.total_refunded=money(total_refunded);
			returnModel.saveCurrentReturn();
		}
		
		
		function removeReturnItem(return_id, product_id){
			array = current_return.order_return_line_items.sort(predicatBy("price", 1));
			count = 0;
			new_items = [];
			for( var i=0; i < current_return.order_return_line_items.length; i++){
				if (current_return.order_return_line_items[i].product_id === product_id && count === 0){
					count++;
				}else{
					new_items.push({id: parseInt(new_items.length)+parseInt(1), name: current_return.order_return_line_items[i].name, product_id: current_return.order_return_line_items[i].product_id, price: current_return.order_return_line_items[i].price, nontax: current_return.order_return_line_items[i].nontax});
				}
			}
			current_return.order_return_line_items = new_items;
			totalReturn();
			returnPage();
		}
		
		function cancelReturn(){
			dbOrderReturns.remove({where: {field: "status", compare: "equals", value: "open"}});
			localStorage.setItem('dbOrderReturns', JSON.stringify(dbOrderReturns.find()));
			dbOrderReturns.commit();
			current_return=null;
			returnPage();
		}
		
		
		
		
	// Server calls
		
		function returnGetOrder(id){
			$.post("/api4/return_get_order.json", {api_token: current_company.api_token, order_id: id}, function(data) {
				if( data.status == 1 ){
					
					if( !current_return ){ current_return = new newReturnModel(); }
					
					var return_data = JSON.parse( data.order_data );
					original_sale = return_data;
					current_return.purchased_items = return_data.order_line_items;
					current_return.order_id = return_data.id;
					current_return.tax_rate = return_data.tax_rate*0.01;
					current_return.order_payments = return_data.order_payments;
					totalReturn();
					returnPage();

				}else{
					returnFocusCheck();
					return alert('Item/Sale not found');
				}
				
			}, 'json');
		}
	
	
	
	// Helpers
		
		function predicatBy(prop, direction){
		   return function(a,b){
		      if( a[prop] > b[prop]){
		          return 1*direction;
		      }else if( a[prop] < b[prop] ){
		          return -1*direction;
		      }
		      return 0;
		   }
		}
		
		
		function store_address(){
			var address = current_store.address + '<br>';
			if( current_store.address2 ){ address += current_store.address2 + '<br>'; }
			address += current_store.city + ', ' + current_store.state + ' ' + current_store.zip;
			return address;
		}
	
	
	
	// Payments
		
		function returnPaymentScreen(){
			// Detect if a Credit Card Was Used
			var cardFound = null;
			for( var i=0;i<current_return.order_payments.length;i++ ){
				if (current_return.order_payments[i].payment_type == 'credit_card'){
					cardFound = true;
				}
			}
			if( cardFound ){
				document.getElementById('returnCreditCardButton').style.display = 'block';
				showReturnPaymentMethod('credit_card');
			}else{
				document.getElementById('returnCreditCardButton').style.display = 'none';
			}
			showPage('returnsPaymentPage');
		}
		
		function addPaymentToReturn(paymentAmount, paymentType, paymentStatus, ccLastFour, TransactionId, AuthCode){
			current_return.order_return_payments.push({
				id: current_return._id + "RP" + current_return.order_return_payments.length,
			  	amount: paymentAmount,
			  	payment_type: paymentType,
			  	status: paymentStatus,
			  	card_last_four: ccLastFour,
			  	transaction_id: TransactionId,
			  	authorization_id: AuthCode
			});
			totalReturn();
			returnPage();
			showPage('returnsPage');
			if (paymentType == 'cash'){adjustTill(parseFloat(paymentAmount)*(-1));}
		}
		
		
	// Complete return and upload data
		
		function completeReturn(){
			
			// Function Variables
			var line_items = ''; var taxable = 0; var subtotal = 0; var credit_card = 0; var gift_card = 0; var cash = 0.00;
			
			// If the return has no items, cancel it
			if( current_return.order_return_line_items.length == 0 ){ cancelReturn(); }
			
			// Display the line items on the receipt and get subtotal and tax
			for( var i=0; i<current_return.order_return_line_items.length; i++ ){
				line_items += '<tr><td>' + current_return.order_return_line_items[i].name + '</td><td>' + displayMoney(current_return.order_return_line_items[i].price) + '</td></tr>';
				subtotal += parseFloat(current_return.order_return_line_items[i].price);
				if( current_return.order_return_line_items[i].nontax == 0 ){
					taxable += parseFloat(current_return.order_return_line_items[i].price);
				}
			}
			
			// Get Totals
			for( var i=0; i<current_return.order_return_payments.length; i++){
				if (current_return.order_return_payments[i].payment_type == 'cash'){
					cash += parseFloat(current_return.order_return_payments[i].amount);
				}
				if (current_return.order_return_payments[i].payment_type == 'credit_card'){
					credit_card += parseFloat(current_return.order_return_payments[i].amount);
				}
				if (current_return.order_return_payments[i].payment_type == 'gift_card'){
					gift_card += parseFloat(current_return.order_return_payments[i].amount);
				}
			}
			
			// Display Receipt
			$('.returnReceiptSubTotal').html(displayMoney(current_return.subtotal));
			$('.returnReceiptTax').html(displayMoney(current_return.tax));
			$('.returnReceiptTotal').html(displayMoney(current_return.total));
		
			$('.returnReceiptCash').html(displayMoney(cash));
			$('.returnReceiptCreditCard').html(displayMoney(credit_card));
			$('.returnReceiptGiftCard').html(displayMoney(gift_card));
		
			document.getElementById('innerReturnReceiptProductList').innerHTML = line_items;
			$('.companyNameReturn').html(current_company.company_name);
			
		
			document.getElementById("returnbarcode").innerHTML = code128(current_return._id);
			document.getElementById("returnReceiptBarCodeId").innerHTML = current_return._id;
			
			current_return.status = 1;
			returnModel.saveCurrentReturn();
			showPage('returnReceiptScreenPage');
			setTimeout(function(){window.print();syncOrderReturn(current_return._id);}, 200);
		}
	
		function syncOrderReturn(order_return_id){
			var postData = {api_token: current_company.api_token, returnData: JSON.stringify( returnModel.get_return(order_return_id) )};
			$.post("/api4/sync_return.json",  postData, function(data) {
				if (data.status == 1){
					dbOrderReturns.remove({where: {field: '_id', compare: 'equals', value: order_return_id}});
				}else{
					dbOrderReturns.update({data: {status: 3}, where: {field: '_id', compare: 'equals', value: order_return_id}});
				}
			})
			.error(function() {
				dbOrderReturns.update({data: {status: 3}, where: {field: '_id', compare: 'equals', value: order_return_id}});
			})
			.complete(function(){
				localStorage.setItem('dbOrderReturns', JSON.stringify(dbOrderReturns.find()));
				dbOrderReturns.commit();
				current_return=null;
				returnPage();
				
			});
		}
	
	

	// OLD BELOW
	

	


	// Return Payment Screen
	

	
	function addReturnCashAmmount(amount){
		cashAmount+=money(amount)
		$('#returnAmountField').val(cashAmount.toFixed(2));
	}
	
	function showReturnPaymentMethod(method){
		
		// If this is cash
		if( method == 'cash' ){
			document.getElementById('cashReturnPayment').style.display="block";
			document.getElementById('return-payment-credit-card').style.display="none";
		}
		
		// If we are refunding a credit card
		if (method == 'credit_card'){
			
			// Show the card portion
			document.getElementById('cashReturnPayment').style.display="none";
			document.getElementById('return-payment-credit-card').style.display="block";
			
			// Display existing cards to choose from for refunding
			var existing_card_html = '';
			for( var i=0; i<current_return.order_payments.length; i++ ){
				if( current_return.order_payments[i].payment_type == 'credit_card' ){
					existing_card_html += '<div class="return-credit-card text-center" id="card' + current_return.order_payments[i].id + '">';
					existing_card_html += 	'<h3>Original Amount: ' + displayMoney(current_return.order_payments[i].amount) + '</h3>';
					existing_card_html += 	'<p>Card Number: **** **** **** ' + current_return.order_payments[i].card_last_four + '</p>';
					existing_card_html += 	'<input type="button" value="Refund Card " onclick="selectReturnCreditCard(\'' + current_return.order_payments[i].id + '\')" class="btn btn-success btn-sm">';
					existing_card_html += '</div>';
				}
			}
			document.getElementById('refund-existing-credit-cards').innerHTML = existing_card_html;
			
		}
	}
	
	function selectReturnCreditCard(id){
		// find the payment
		for( var i=0;i<current_return.order_payments.length;i++){
			if(current_return.order_payments[i].id.toString() === id.toString()){
				var payment = current_return.order_payments[i];
			}
		}
		// If payment found, refund it
		if(payment){
			ProcessingAlert('processingReturnPayment');
			$.post("/payment_api_base/credit_card_refund.json", {api_token: current_company.api_token, transaction_id: payment.transaction_id, amount: current_return.amount_owed, order_id: current_return.order_id, void_trans: 0}, function(data) {
				if (data.status == 1){	
					addPaymentToReturn(data.amount, 'credit_card', 'complete', data.card_last_four, data.transaction_id, data.authcode);
				}else{
					alert("I'm sorry, I could not refund this card.")
				}
			}, 'json').error(function(){}).complete(function(){ clearAlert(null); });
			
			
		}
	}
	
	function addReturnPayment(paymentType){
		if (paymentType == 'cash'){
			addPaymentToReturn(document.querySelector('#returnAmountField').value, paymentType, 1, null, null, null);
		}
		if (paymentType == 'credit_card'){
			// Replaced In One Click Refund # => selectReturnCreditCard
		}
	}
	
	
	function manual_refund_card(){
		
		// Assign the values
		var card_name = document.getElementById('return-payment-card-name').value;
		var number = document.getElementById('return-payment-card-number').value;
		var month = document.getElementById('return-payment-card-exp-month').value;
		var year = document.getElementById('return-payment-card-exp-year').value;
		var cvv = document.getElementById('return-payment-card-cvv').value;
		
		// If the number or cvv is missing alert
		if( number == '' || cvv == '' ){ return alert('The card number and CVV fields can not be blank.'); }
		
		// Try to proccess payment
		ProcessingAlert('processingReturnPayment');
		$.post("/payment_api_base/credit_credit_card.json", { api_token: current_company.api_token, card_name: card_name, card_number: number, card_exp_month: month, card_exp_year: year, card_cvv: cvv, refund_amount: current_return.amount_owed }, function(data) {
			if (data.status == 1){	
				addPaymentToReturn(data.amount, 'credit_card', 'complete', data.card_last_four, data.transaction_id, data.authcode);
			}else{
				alert("I'm sorry, I could not refund this card.")
			}
		}, 'json').complete(function(){
			 clearAlert(null); 
		 });
		
	}
	





	// Sync Return
	
	
;
