$(document).ready(function(){
	// Set all forms to return false
	$("form").submit(function () { return false; });
	
	// Correct the window size
	
	$(document).resize(function(){ configureSize(); });
	
	
	// Load the Register
	setTimeout(function(){
		stayFresh();
		checkLogin();
		reloadStores();
		globalCurrencyCode = localStorage.getItem('currency_code');
		if(globalCurrencyCode){
			globalCurrencyCode = '$';
			localStorage.setItem('currency_code', '$');
		}
		if (currentSale == null){
			loadOrder();
		}
	}, 200);
});

function loadOrder(){
	cached_sale = dbOrders.find({where: {field: "status", compare: "equals", value: "open"}})[0];
	if(cached_sale != null){
		currentSale = cached_sale;
		totalOrder();
	}
}

function checkLogin(){
	displayLogin();
	if( !globalEmployeeId || !globalStoreId || !globalRegisterId ){
		$('#wrapper').hide();
	}else{
		
		loadRegister();
		
		$('#wrapper').fadeIn(400);
		if (localStorage.getItem('register_status') == 0 ){ return openRegister(); }

	}
}

function loadRegister(){
	document.getElementById('companyName').innerHTML = globalCompanyName;
	document.getElementById('storeName').innerHTML = globalStoreName;
	document.getElementById('registerName').innerHTML = globalRegisterName;
	document.getElementById('employeeName').innerHTML = globalEmployeeName;
	setCurrencyCode();
	showPage(currentPage);
	getProductsFromServer();
	getCouponsFromServer();
	checkStatus();
}


//
//
// Stay Fresh
//
//
//

function stayFresh(){
	console.log('stayFresh');
	syncOfflineOrders(); // ok
	syncOfflineReturns(); 
	syncOfflineTimeCards(); // ok
}

function syncOfflineOrders(){
	console.log('syncOfflineOrders');
	offline_orders = dbOrders.find({where: {field: 'status', compare: 'equals', value: 'completedoffline'}});
	for (i=0;i<offline_orders.length;i++){
		syncOrder(offline_orders[i].id);
	}
}

function syncOfflineReturns(){
	console.log('syncOfflineReturns');
	offline_returns = dbOrderReturns.find({where: {field: 'status', compare: 'equals', value: 'completedoffline'}});
	for (i=0;i<offline_returns.length;i++){
		syncOrderReturn(offline_returns[i].id);
	}
}

function syncOfflineTimeCards(){
	console.log('syncOfflineTimeCards');
	$.post("/api3/syncOfflineTimeCards.json", {api_token: globalCompanyToken, store_id: globalStoreId, timecards: JSON.stringify(dbTimesheets.find())}, function(data) {
		dbTimesheets.clear();
		dbTimesheets.load({data: JSON.stringify(data)});
		localStorage.setItem('dbTimesheets', JSON.stringify(dbTimesheets.find()));
		dbTimesheets.commit();
	}, 'json');
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// LOG IN
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function displayLogin(){
	console.log('displayLogin');
	$('#wrapper').hide();
	// Hide login, select store and select register
	$('.login-options').hide();
	if(!globalEmployeeId){
		if( globalCompanyID != null && globalCompanyID != '' ){
			$('#employee_company_id').val( globalCompanyID );
			$('#employee_company_id').parent().hide();
		}
		$('#login-wrapper').show();
		return $('#employee_company_id').focus();
	}
	if(!globalStoreId){
		displayStoreData();
		return $('#select-store-wrapper').show();
	}
	if(!globalRegisterId){
		loadSelectRegisters();
		return $('#select_register_wrapper').show();
	}
}


function reloadStores(){
	$.post("/api3/loadStores.json", {api_token: globalCompanyToken}, function(data) {
        globalStores = data.stores;
        localStorage.setItem('all_stores', JSON.stringify(data.stores));
        globalRegisters = data.registers;
        localStorage.setItem('all_registers', JSON.stringify(data.registers));
	}, 'json')
	.complete(function(){
        displayStoreData();
	});
}

function displayStoreData(){
	storeData = '';
    for (i=0;i<globalStores.length;i++){
		storeData += '<div class="col-xs-12 col-sm-6 col-md-4 col-lg-3 store-box"><h4>' + globalStores[i].name + '</h4><p>' + globalStores[i].address + '<br>' + globalStores[i].city + ', ' + globalStores[i].state + ' ' + globalStores[i].zip + '</p><input type="button" value="Select Store" class="btn btn-primary btn-lg" onclick="selectStore(\''+globalStores[i].id+'\')" /></div>';
    }
	if(globalStores.length == 0){
		storeData = '<div class="row"><div class="col-sm-12 text-center" style="background-color:#eee;padding:10px;"><h3 style="margin:0;padding:0;">You must add a store profile in the <a href="/admin">admin section</a> before you can use Evendra.</h3></div></div>';
	}
	$('#store-data').html(storeData);
}

function tryToLogin(){
	postData = { company_id: $('#employee_company_id').val(), username: $('#employee_username').val(), password: $('#employee_password').val() };
	$.post("/api3/tryToLogin.json", postData, function(data) {
           if (data.status == 'ok'){
                globalCompanyToken = data.globalCompanyToken;
                localStorage.setItem('company_token', data.globalCompanyToken);
				globalCompanyID = data.globalCompanyID;
				localStorage.setItem('company_id', data.globalCompanyID);
                globalCompanyName = data.globalCompanyName;
                localStorage.setItem('company_name', data.globalCompanyName);
                globalCompanyName = data.globalCompanyName;
                localStorage.setItem('company_name', data.globalCompanyName);
                globalEmployeeId = data.globalEmployeeId;
                localStorage.setItem('employee_id', data.globalEmployeeId);
                globalEmployeeName = data.globalEmployeeName;
                localStorage.setItem('employee_name', data.globalEmployeeName);
                globalStores = data.globalStores;
                localStorage.setItem('all_stores', JSON.stringify(data.globalStores));
                globalRegisters = data.globalRegisters;
                localStorage.setItem('all_registers', JSON.stringify(data.globalRegisters));
           }else{
			   $('#login_wrapper>.notifi').html('The username or password is incorrect.')
			   $('#login_wrapper>.notifi').show();
           }
	}, 'json')
	.error(function() { 
		alert('You must be connected to the internet to login.');
	}).complete(function(){
        checkLogin();
	});
}

function selectStore(store_id){
	console.log('selectStore');
    for (i=0;i<globalStores.length;i++){
        if(globalStores[i].id == store_id){
            localStorage.setItem('store_address', globalStores[i].address + '<br>' + globalStores[i].city + ', ' + globalStores[i].state + ' ' + globalStores[i].zip);
            localStorage.setItem('store_id', globalStores[i].id);
            localStorage.setItem('store_name', globalStores[i].name);
            localStorage.setItem('tax_rate', money(globalStores[i].tax_rate/100));
			localStorage.setItem('store_gateway', globalStores[i].gateway);
			localStorage.setItem('currency_code', globalStores[i].currency_code);
            globalStoreAddress = globalStores[i].address + '<br>' + globalStores[i].city + ', ' + globalStores[i].state + ' ' + globalStores[i].zip;
            globalStoreId = globalStores[i].id;
            globalStoreName = globalStores[i].name;
            globalTaxRate = money(globalStores[i].tax_rate/100);
			globalGateway = globalStores[i].gateway;
			globalCurrencyCode = globalStores[i].currency_code;
			if(!globalStores[i].currency_code){
				globalCurrencyCode = '$';
				localStorage.setItem('currency_code', '$');
			}
        }
    }
    checkLogin();
}

function loadSelectRegisters(){
	// Regresh Register List
	postData = { api_token: globalCompanyToken };
	$.post("/api3/refreshRegisterList.json", postData, function(data) { 
		if (data.status == 'ok'){ 
			
		globalRegisters = data.globalRegisters;
        localStorage.setItem('all_registers', JSON.stringify(data.globalRegisters)); 
	} }, 'json').complete(function(){
		// Display Register List
	    registerClosedData = '';
		registerOpenData = '';
	    for (i=0;i<globalRegisters.length;i++){
			if(globalRegisters[i].current_employee){ current_user = '<b>CURRENT USER:</b> '+globalRegisters[i].current_employee; }else{ current_user = ''; }
			if(globalRegisters[i].status == 0){
				registerClosedData+='<div class="col-xs-12 col-sm-6 col-md-4 col-lg-3 store-box closed"><h4>' + globalRegisters[i].name + '</h4><p>Status: Closed<p><input type="button" value="Open Register" class="btn btn-primary btn-lg" onclick="selectRegister(\'' + globalRegisters[i].id + '\')" /></div>';
			}else{
				registerOpenData+='<div class="col-xs-12 col-sm-6 col-md-4 col-lg-3 store-box opened"><h4>' + globalRegisters[i].name + '</h4><p><b>Status:</b> Open</p>' + current_user + '<br><br><input type="button" value="Select Register" class="btn btn-primary btn-lg" onclick="selectRegister(\'' + globalRegisters[i].id + '\')" /></div>';
			}
			current_user = null;
		}
		if(globalRegisters.length == 0){
		    $('.has-registers').hide();
			$('#no-registers').show();
		}else{
		    $('.has-registers').show();
			$('#no-registers').hide();
		}
	    $('#registerClosedData').html(registerClosedData);
		$('#registerOpenData').html(registerOpenData);
	});
	
}

function selectRegister(register_id){
	for (i=0;i<globalRegisters.length;i++){
		if(globalRegisters[i].id == register_id){
			globalRegisterId = register_id;
			globalRegisterName = globalRegisters[i].name;
			localStorage.setItem('register_id', globalRegisterId);
			localStorage.setItem('register_name', globalRegisterName);
			localStorage.setItem("till", money(globalRegisters[i].till).toFixed(2) );
			localStorage.setItem('register_status', globalRegisters[i].status);
		}
	}
	checkLogin();
}


//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Models
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function newSale(){
	result = dbOrders.find({where: {field: "status", compare: "equals", value: "open"}})[0];
	if (result){
		return result
	}else{
		timestring = getTimeString('no').toString();
		dbOrders.insert([{
			id: globalRegisterId + timestring + 'R',
			status: 'open',
			created_at: timestring,
			completed_at: '',
			item_count: 0,
			subtotal: 0,
			tax_rate: globalTaxRate,
			tax: 0,
			discount: 0,
			total: 0,
			net_profit: 0,
			tip: 0,
			amount_due: 0,
			coupon_ids: [],
			store_id: globalStoreId,
			store_name: globalStoreName,
			register_id: globalRegisterId,
			register_name: globalRegisterName,
			customer_id: '',
			customer_name: '',
			employee_id: globalEmployeeId, 
			employee_name: globalEmployeeName,
			order_line_items: [],
			order_payments: []
		  }]);
		return dbOrders.find({where: {field: "status", compare: "equals", value: "open"}})[0];
	}
}

function newReturn(){
	result = dbOrderReturns.find({where: {field: "status", compare: "equals", value: "open"}})[0];
	if(result){
		return result;
	}else{	
		timestring = getTimeString('no').toString();
		dbOrderReturns.insert([{
			id:  'RT' + globalRegisterId + timestring, 
			status: 'open', 
			created_at: timestring, 
			completed_at: null, 
			customer_name: null,
			customer_id: null,
			
			item_count: 0,
			subtotal: 0.00,
			tax_rate: globalTaxRate,
			tax: 0.00,
			total: 0.00,
			amount_owed: 0.00,
			tax_refunded: 0.00,
			total_refunded: 0.00,
			
			purchased_items: [],
			order_payments: [],
			order_return_line_items: [],
			order_return_payments: [],
			
			store_id: globalStoreId,
			store_name: globalStoreName,
			register_id: globalRegisterId,
			register_name: globalRegisterName,
			
			order_id: null,
			employee_id: globalEmployeeId,
			employee_name: globalEmployeeName,
		}]);
		return dbOrderReturns.find({where: {field: "status", compare: "equals", value: "open"}})[0];
	}
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

function saveDb(db){
	localStorage.setItem(db.toString());
}

function money(num){
	number = parseFloat(Number(num).toFixed(2));
	return number;
}

function setCurrencyCode(){
	globalCurrencyCode = localStorage.getItem('currency_code');
}

function displayMoney(num){
	number = parseFloat(num).toFixed(2);
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
	return (globalCurrencyCode+format.split("").reverse().join("")+'.'+number.split('.')[1]).toString();
}

function onFocuser(id, value){
	if($('#'+id).val() == value){
		$('#'+id).val('');
	}
}

function onBlurer(id, value){
	if($('#'+id).val() == ''){
		$('#'+id).val(value);
	}
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Data Controller
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function adjustTill(amount){
	newTill = (money(localStorage.getItem("till"))+money(amount)).toFixed(2);
	localStorage.setItem("till", newTill );
	for (i=0;i<globalRegisters.length;i++){
		if(globalRegisters[i].id == globalRegisterId){
			globalRegisters[i].till = newTill
		}
	}
	localStorage.setItem('all_registers', JSON.stringify(globalRegisters));
}


function getProductsFromServer(){
	postData = { api_token: globalCompanyToken, status: "load"};
	$.post("/api3/loadProducts.json", postData, function(data) {
		insertProducts(data.items);
	}, 'json')
	.error(function() { 
		insertProducts(JSON.parse(localStorage.getItem('dbProducts')));
	}).complete(function(){

	});
}

function insertProducts(products){
	dbProducts.clear();
	for (i = 0; i < products.length; i++){
		dbProducts.insert([{product_id: products[i].id, name: products[i].name, upc: products[i].upc, sku: products[i].sku, ean: products[i].ean, m_sku: products[i].m_sku, price: products[i].price, cost: products[i].cost, nontax: products[i].nontax, return_price: products[i].return_price, tags: products[i].tags}]);
	}
	dbProducts.commit();
	localStorage.setItem("dbProducts", JSON.stringify(dbProducts.find()));
}


function getCouponsFromServer(){
	postData = { api_token: globalCompanyToken, status: "load"};
	$.post("/api3/getCouponsFromServer.json", postData, function(jsondata) {
		dbCoupons.load({ data: jsondata });
		localStorage.setItem('dbCoupons', JSON.stringify(jsondata))
	}, 'json')
	.error(function() { 
		dbCoupons.load({ data: JSON.parse(localStorage.getItem('dbCoupons')) });
	}).complete(function(){

	});
}


function saveOrder(){
	if(currentSale){
		dbOrders.update({data: currentSale, where:{field: "id", compare: "equals", value: currentSale.id}});
		localStorage.setItem("dbOrders", JSON.stringify(dbOrders.find()));
	}else{
		localStorage.setItem("dbOrders", JSON.stringify(dbOrders.find()));
	}
}

function saveReturn(){
	if(currentReturn){
		dbOrderReturns.update({data: currentReturn, where:{field: "id", compare: "equals", value: currentReturn.id}});
		localStorage.setItem("dbOrderReturns", JSON.stringify(dbOrderReturns.find()));
	}else{
		localStorage.setItem("dbOrderReturns", JSON.stringify(dbOrderReturns.find()));
	}
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Visual Controller
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function showPage(id){
	if(!currentPage){
		currentPage = '#cashRegisterPage';
		return showPage(currentPage);
	}
	if(id != currentPage){
		new_currentPage = currentPage.replace('#', '');
		new_id = id.replace('#', '');
		document.getElementById(new_currentPage).classList.remove('active');
		document.getElementById(new_currentPage+'-right').classList.remove('active');
		
		document.getElementById(new_id).classList.add('active');
		document.getElementById(new_id+'-right').classList.add('active');
		
		//$(currentPage).hide();
		//$(currentPage+'-right').hide();
		//$(id).show();
		//$(id+'-right').show();
	}else{
		new_currentPage = currentPage.replace('#', '');
		new_id = id.replace('#', '');
		document.getElementById(new_currentPage).classList.remove('active');
		document.getElementById(new_currentPage+'-right').classList.remove('active');
		
		document.getElementById(new_id).classList.add('active');
		document.getElementById(new_id+'-right').classList.add('active');
		
		//$(currentPage).hide();
		//$(currentPage+'-right').hide();
		//$(id).show();
		//$(id+'-right').show();
	}
	// Page Specific
	if(id == '#cashRegisterPage'){
		displayOrder();
		$('.topBarButton').removeClass("on");
		$(id+'Button').addClass("on");
		console.log('scan')
		resetScanBox();
	}
	if(id == '#receiptScreenPage'){
		$('#returnReceiptWrapper').hide();
		$('#receiptWrapper').show();
	}
	if(id == '#returnReceiptScreenPage'){
		$('#receiptWrapper').hide();
		$('#returnReceiptWrapper').show();
	}
	if (id == '#timesheetPage'){
		$('.topBarButton').removeClass("on");
		$(id+'Button').addClass("on");
		localStorage.setItem('currentPage', currentPage);
		$('#timeSheetInfoArea').html('<div class="innerTimesheetArea"><h1>Clocking In/Out</h1>To clock in or out, enter your username and password in the right hand menu. &#8594;</div>');
	}
	if(id == '#returnsPage'){
		localStorage.setItem('currentPage', currentPage);
		$('.topBarButton').removeClass("on");
		$(id+'Button').addClass("on");
		returnPage();
	}
	if(id == '#optionsPage'){
		localStorage.setItem('currentPage', currentPage);
		$('.topBarButton').removeClass("on");
		$(id+'Button').addClass("on");
		returnPage();
	}
	currentPage = id;
}



//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Register Page
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function checkStatus(){
	loadOrder();
	if(currentSale){
		displayOrder();
	}else{
		readyRegister();
	}
}

function readyRegister(){
	$('#current_order').hide();
	$('#no_order').show();
	$('.register_line_items').html('');
	//showPage('#cashRegisterPage');
	resetScanBox();
}

function resetScanBox(){
	$('#scanField').focus().val('');
	$('#qty').val('1');
}

function addItemToSale(id, qty){
	if(!id){
		id = $('#scanField').val();
		qty = $('#qty').val();
	}
	if(!id){
		return false;
	}
	query = {where: {join: "or", terms: [{field: "product_id", compare: "equals", value: id.toString()},{field: "upc", compare: "equals", value: id.toString()},{field: "sku", compare: "equals", value: id.toString()},{field: "ean", compare: "equals", value: id.toString()},{field: "m_sku", compare: "equals", value: id.toString()}]}};
	product = dbProducts.find(query)[0];
	if(!product){
		return itemSearch(id.toString());
	}
	if (!currentSale){
		currentSale = newSale();
	}
	for (i=0;i<currentSale.order_line_items.length;i++){
		if (currentSale.order_line_items[i].product_id == product.product_id){
			// Existing Product
			currentSale.order_line_items[i].qty = parseInt(currentSale.order_line_items[i].qty)+parseInt(qty);
			currentSale.order_line_items[i].total = parseFloat( (currentSale.order_line_items[i].qty*product.price).toFixed(2)	); 
			currentSale.order_line_items[i].cost = parseFloat( (currentSale.order_line_items[i].qty*product.cost).toFixed(2) );
			currentSale.order_line_items[i].origional_total = parseFloat( (product.price*currentSale.order_line_items[i].qty).toFixed(2) );
			currentSale.order_line_items[i].net_profit = parseFloat( ((product.price-product.cost)*currentSale.order_line_items[i].qty).toFixed(2) );
			return totalOrder();
		}
	}
	// New Product
	item = {
		name: product.name, 
		product_id: product.product_id, 
		price: product.price, 
		origional_price: product.price, 
		qty: qty, 
		discount: 0,
		total: money(qty*product.price), 
		cost: money(qty*product.cost), 
		origional_total: money(product.price*qty), 
		sku: product.sku, 
		net_profit: money( (product.price-product.cost)*qty ), 
		nontax: product.nontax,
		appliedCoupon: 0
	};
	currentSale.order_line_items.push(item);
	totalOrder();
}

// Item Search 

function itemSearch(q){
	products = dbProducts.find({where: {field: "tags", compare: "contains", value: q.toLowerCase() }});
	if (products.length >= 1){
		items = '';
		$('#posArea').hide();
		$('#itemSearch').show();
		for (i=0;i<products.length;i++){
			items += '<tr><td><b>' + products[i].name + '</b></td><td><b>' + globalCurrencyCode + parseFloat(products[i].price).toFixed(2) + '</b></td><td class="text-right"><input class="btn btn-go" value="Add Item" onclick="selectItem(\'' + products[i].product_id + '\', \'' + $('#qty').val() + '\')" /></td></tr>';
			
			//items += '<div class="searchItemBox"><p><b>' + products[i].name + '</b><br />' + globalCurrencyCode + parseFloat(products[i].price).toFixed(2) + '</p><input class="buttons green greenbuttons icon add" value="Add Item" onclick="selectItem(\'' + products[i].product_id + '\', \'' + $('#qty').val() + '\')" /></div>'
		}
		$('#item-search-items').html(items);
	}else{
		alertCode('productNotFound', 'resetScanBox();');
	}
	resetScanBox();
}

function hideItemSearch(){
	$('#posArea').show();
	$('#itemSearch').hide();
}

function selectItem(product_id, qty){
	hideItemSearch();
	addItemToSale(product_id, qty);
}

// End Item Search

function totalOrder(){
	currentSale.subtotal=0;currentSale.tax=0;currentSale.tip=0;currentSale.total=0;taxable=0;currentSale.item_count=0;currentSale.discount=0;currentSale.net_profit=0;
	// Remove item if qty = 0
	for (i=0;i<currentSale.order_line_items.length;i++){
		if(parseInt(currentSale.order_line_items[i].qty) == 0){
			currentSale.order_line_items.remove(currentSale.order_line_items[i]);
		}
	}
	for (i=0;i<currentSale.order_line_items.length;i++){
		currentSale.discount+=money(currentSale.order_line_items[i].discount);
		currentSale.net_profit+=money(currentSale.order_line_items[i].net_profit);
		currentSale.item_count+=parseInt(currentSale.order_line_items[i].qty);
		currentSale.subtotal += currentSale.order_line_items[i].total;
		if(currentSale.order_line_items[i].nontax != 1){
			taxable += money(currentSale.order_line_items[i].total);
		}
	}
	currentSale.tax = money(taxable*globalTaxRate);
	currentSale.tip = 0;
	currentSale.total = money(currentSale.subtotal) + money(currentSale.tax) + money(currentSale.tip);
	currentSale.amount_due=money(currentSale.total);
	for(i=0;i<currentSale.order_payments.length;i++){
		currentSale.amount_due-=money(currentSale.order_payments[i].amount);
	}
	saveOrder();
	displayOrder();
}

function displayOrder(){
	if(currentSale == null){
		$('#current_order').hide();
		$('#no_order').show();
		return readyRegister();
	}else{
		$('#no_order').hide();
		$('#current_order').show();
	}
	$('.order-item_count').html(currentSale.item_count);
	$('.order-subtotal').html(displayMoney(currentSale.subtotal));
	$('.order-tax').html(displayMoney(currentSale.tax));
	$('.order-total').html(displayMoney(currentSale.total));
	if(money(currentSale.amount_due)<= 0.00){
		$('#RightPaymentButton').hide();
		$('#RightCompleteButton').show();
		$('.due-title').html('CHANGE');
		$('.amount-due').html(displayMoney(currentSale.amount_due*-1).replace('-',''));
	}else{
		$('#RightPaymentButton').show();
		$('#RightCompleteButton').hide();
		$('.due-title').html('DUE');
		$('.amount-due').html(displayMoney(currentSale.amount_due));
	}
	// Customer
	if(!currentSale.customer_name){
		$('#customerNameBox').hide();
		$('#customerSearchBox').show();
		$('#add-new-customer-btn').show();
		//document.getElementById('addNewCustomerButton').className = 'addNewCustomerButton'; What did this use to do?
	}else{
		$('#add-new-customer-btn').hide();
		$('#customerNameBox').show();
		$('#customerNameBox').html('<b>Name: </b>' + currentSale.customer_name);
		$('#customerSearchBox').hide();
	}
	items = '';
	for (n = 0; n < currentSale.order_line_items.length; n++){
		items += "<tr><td><b>"+ currentSale.order_line_items[n].name +"</b></td><td class='hidden-sm'><b>"+ currentSale.order_line_items[n].sku +"</b></td><td width='110' id='" + currentSale.order_line_items[n].product_id + "_price' ondblclick=\"lineItemEditable('price', '" + currentSale.order_line_items[n].product_id + "_price', '"+ currentSale.order_line_items[n].price +"')\"><b>"+ displayMoney(currentSale.order_line_items[n].price) +"</b></td><td style='width:125px;' ondblclick=\"lineItemEditable('qty', '" + currentSale.order_line_items[n].product_id + "_qty', '"+ currentSale.order_line_items[n].qty +"')\" id='" + currentSale.order_line_items[n].product_id + "_qty'><b>"+ currentSale.order_line_items[n].qty +"</b></td><td class='row'><b>"+ displayMoney(currentSale.order_line_items[n].total) +"</b></td><td class='row' width='95'><a class='btn btn-danger btn-line-item' onclick='addItemToSale(\""+ currentSale.order_line_items[n].product_id +"\", -1)' >Remove</a></td></tr>";
	}
	$('.register_line_items').html(items);
	setTimeout(function(){ resetScanBox(); }, 50);
}

function lineItemEditable(type, id, value){
	if (type=='qty'){
		$('#'+id.toString()).html('<div class="input-group"><input type="text" class="form-control" placeholder="'+ value +'" id="' + id + '_field"><span class="input-group-btn"><button name="commit" type="submit" class="btn btn-go" onclick="inlineQtyChange(\'' + id.replace('_qty', '') + '\')">Save</button></span></div>');
	}
	if (type=='price'){
		//$('#'+id.toString()).html('<input type="text" value="'+ money(value).toFixed(2) +'" id="' + id + '_field" onchange="changeItemPrice(\'' + id.replace('_price', '') + '\', this.value)" class="editBox">');
		$('#'+id.toString()).html('<div class="input-group"><span class="input-group-addon">$</span><input type="text" class="form-control" placeholder="'+ money(value) +'" id="' + id + '_field"><span class="input-group-btn"><button name="commit" type="submit" class="btn btn-go" onclick="inlinePriceChange(\'' + id.replace('_price', '') + '\')">Save</button></span></div>');
		$('#'+id.toString()).css('width', '250px');
	}
	$('#'+id+'_field').focus();
}

function inlineQtyChange(id){
	changeItemQty(id, $('#' + id + '_qty_field').val());
}

function inlinePriceChange(id){
	changeItemPrice(id, $('#' + id + '_price_field').val());
	$('#'+id.toString()).css('width', 'auto');
	$('#'+id.toString()).html(displayMoney($('#' + id + '_price_field').val()));
}

function changeItemQty(id, qty){
	if(qty){
		for(i=0;i<currentSale.order_line_items.length;i++){
			if(currentSale.order_line_items[i].product_id == id){
				// Existing Product
				currentSale.order_line_items[i].qty = parseInt(qty);
				currentSale.order_line_items[i].total = parseFloat( (currentSale.order_line_items[i].qty*currentSale.order_line_items[i].price).toFixed(2) ); 
				currentSale.order_line_items[i].cost = parseFloat( (currentSale.order_line_items[i].qty*currentSale.order_line_items[i].cost).toFixed(2) );
				currentSale.order_line_items[i].origional_total = parseFloat( (currentSale.order_line_items[i].price*currentSale.order_line_items[i].qty).toFixed(2) );
				currentSale.order_line_items[i].net_profit = parseFloat( ((currentSale.order_line_items[i].price-currentSale.order_line_items[i].cost)*currentSale.order_line_items[i].qty).toFixed(2) );
			}
		}
	}
	return totalOrder();
}

function changeItemPrice(id, price){
	if(price){
		for(i=0;i<currentSale.order_line_items.length;i++){
			if(currentSale.order_line_items[i].product_id == id){
				// Existing Product
				currentSale.order_line_items[i].price = money(price);
				currentSale.order_line_items[i].total = parseFloat( (currentSale.order_line_items[i].qty*currentSale.order_line_items[i].price).toFixed(2) ); 
				currentSale.order_line_items[i].cost = parseFloat( (currentSale.order_line_items[i].qty*currentSale.order_line_items[i].cost).toFixed(2) );
				currentSale.order_line_items[i].net_profit = parseFloat( ((currentSale.order_line_items[i].price-currentSale.order_line_items[i].cost)*currentSale.order_line_items[i].qty).toFixed(2) );
			}
		}
	}
	return totalOrder();
}


// find add customer

function showAddCustomer(){
	$('#add-new-customer-btn').hide();
	$('#addCustomerBox').slideDown('fast', function() {
	    $('#customerFirstName').focus();
	  });
}

function findCustomer(){
	if ($('#customerSearch').val() == ''){
		alertCode('enterCustomerPhone', 'resetScanBox()');
	}
	postData = {api_token: globalCompanyToken, q: $('#customerSearch').val()};
	$.post("/api3/findCustomer.json", postData, function(data) {
		if (data.status == 'success'){
			addCustomerToOrder(data.customer_name, data.customer_id);
		}else{
			alertCode('customerNotFound', 'resetScanBox()');
		}
	}, 'json')
	.error(function() { 
		alertCode('connectionError', 'resetScanBox()');
	}).complete(function(){
		$('#customerSearch').val('');
	});
}

function addCustomerToDB(){
	postData = {api_token: globalCompanyToken, first_name: $('#customerFirstName').val(), last_name: $('#customerLastName').val(), email: $('#customerEmail').val(), phone: $('#customerPhone').val(), address: $('#customerAddress').val(), city: $('#customerCity').val(), state: $('#customerState').val(), zip: $('#customerZip').val()};
	$.post("/api3/addCustomer.json", postData, function(data) {
		if (data.status == 'success'){
			addCustomerToOrder(data.customer_name, data.customer_id);
		}else{
			alertCode('errorAddingCustomer', 'resetScanBox()');
		}
	}, 'json')
	.error(function() { 
		alertCode('connectionError', 'resetScanBox()');
	});
}

function addCustomerToOrder(customer_name, customer_id){
	currentSale.customer_id = customer_id;
	currentSale.customer_name = customer_name;
	$('#addCustomerBox').slideUp('fast', function() {});
	clearCustomerFields();
	saveOrder();
	return displayOrder();
}

function clearCustomerFields(){
	$('#customerFirstName').val('');
	$('#customerLastName').val('');
	$('#customerEmail').val('');
	$('#customerPhone').val('');
	$('#customerAddress').val('');
	$('#customerCity').val('');
	$('#customerState').val('');
	$('#customerZip').val('');
}



// Coupons

function addCoupon(){
	coupon_code = $('#couponId').val();
	coupon = dbCoupons.find({where: {field: "code", compare: "equals", value: coupon_code}})[0];
	if(coupon){
		
		for (i=0;i<currentSale.order_line_items.length;i++){
			apply_coupon = 1;
			// Dont apply if another coupon is already applied and multi use is 0
			if(currentSale.order_line_items[i].appliedCoupon == 1 && coupon.multiple_coupons == 0){apply_coupon = 0;}
			// Dont apply if minimum order price has not been met
			if(money(currentSale.subtotal) < money(coupon.minimum_order_price)){apply_coupon = 0;}
			// Check if there are required items, if so check if they exist
			if(coupon.required_items.length >= 1){
				if(coupon.required_items_type == 0){
					allItemsThere = 'yes';
					for(s=0;s<coupon.required_items.length;s++){
						exist = 'no';
						for(n=0;n<currentSale.order_line_items.length;n++){
							if(coupon.required_items[s] == currentSale.order_line_items[n].product_id){
								exist = 'yes';
							}
							if(exist == 'no'){
								allItemsThere = 'no';
							}
						}
					}
					if(allItemsThere == 'no'){
						apply_coupon=0;
					}
				}else{
					anyItemFound = 'no';
					for(s=0;s<coupon.required_items.length;s++){
						for(n=0;n<currentSale.order_line_items.length;n++){
							if(coupon.required_items[s] == currentSale.order_line_items[n].product_id){
								anyItemFound = 'yes';
							}
						}
					}
					if(anyItemFound == 'no'){
						apply_coupon=0;
					}
				}
			}
			// Check if coupon is valid for certain products only
			if(coupon.products.length >= 1){
				exist = 'no';
				for (p=0;p<coupon.products.length;p++){
					if (coupon.products[p] == currentSale.order_line_items[i].product_id){
						exist = 'yes';
					}
				}
				if(exist == 'no'){
					apply_coupon=0;
				}
			}
			// Make sure coupon has not been redeemed for sale already
			for(i=0;i<currentSale.coupon_ids.length;i++){
				if(currentSale.coupon_ids[i] == coupon.id){
					apply_coupon=0;
				}
			}
			// If the coupon is valid, apply it
			if(apply_coupon == 1){
				// mark the coupon as used
				currentSale.coupon_ids.push(coupon.id);
				if(coupon.discount_type == 0){
					new_price = currentSale.order_line_items[i].price - (currentSale.order_line_items[i].price*(coupon.discount_value/100));
					currentSale.order_line_items[i].price = new_price;
					currentSale.order_line_items[i].total = new_price*currentSale.order_line_items[i].qty;
					currentSale.order_line_items[i].appliedCoupon = 1;
				}else{
					new_price = currentSale.order_line_items[i].price - coupon.discount_value;
					currentSale.order_line_items[i].price = new_price;
					currentSale.order_line_items[i].total = new_price*currentSale.order_line_items[i].qty;
					currentSale.order_line_items[i].appliedCoupon = 1;
				}
			}
		}
		
		//end if coupon exist
	}
	$('#couponId').val('');
	return totalOrder();
} 


// Payment Screen

var currentPaymentType = '', cashAmount = 0, checkAmount = 0;

function paymentScreen(){
	$('.payment-remaining-field').val( money(currentSale.amount_due) );
	currentPaymentType = 'cashPaymentBox';
	setPaymentType('cashPaymentBox');
	showPage('#paymentScreenPage');
}

function setPaymentType(type){
	// Change type
	if(type != currentPaymentType){ $('#'+currentPaymentType).hide(); $('#'+type).show(); }
	// Type specific commands
	if(type == "creditCardPaymentBox"){ $('#creditCardOptions').show(); $('#magData').focus(); }
	if (type == "giftCardPaymentBox"){ $('#giftMagData').focus(); }
	if (type == "cashPaymentBox"){ cashAmount = 0; }
	currentPaymentType = type;
}

function manualCard(){
	$("#manualCCField").show();
	$("#scanCCField").hide();
}

function scanCreditCard(){
	$("#manualCCField").show();
	$("#scanCCField").hide();
	$('#magData').focus();
}

function addPayment(payment_type){
	// Generate a payment ID
	payment_id = currentSale.id + "P" + currentSale.order_payments.length;
	if (payment_type == 'cash'){ return addCashPayment(payment_id); }
	if (payment_type == 'credit_card'){ return addCreditCardPayment(payment_id); }
	if (payment_type == 'check'){ return addCheckPayment(payment_id); }
	if (payment_type == 'gift_card'){ return addGiftCardPayment(payment_id); }
}

function addCashPayment(payment_id){
	currentSale.order_payments.push({id: payment_id, amount: money($('#amountField').val()), payment_type: "cash", transaction_id: payment_id, authorization_id: ""})
	adjustTill($('#amountField').val());
	exitPaymentScreen();
}

function addCheckPayment(payment_id){
	currentSale.order_payments.push({id: payment_id, amount: parseFloat($('#amountFieldCheck').val()).toFixed(2), payment_type: "check", transaction_id: payment_id, authorization_id: ""})
	exitPaymentScreen();
}

function addCreditCardPayment(payment_id){
	// If integrated
	ProcessingAlert('processingPayment');
	MagData = $('#magData').val();
	if(MagData){
		amount = money($('#amountFieldCC').val()).toFixed(2);
	}else{
		amount = money($('#amountFieldCCManual').val()).toFixed(2);
	}
	// Card Details
	CardNum = $('#creditCardNumber').val();
	ExpDate = $('#cardExpDate').val();
	NameOnCard = $('#cardHolderName').val();
	cv2 = $('#CardCvvNumber').val();
	
	// Check if non integrated
	if (globalGateway === 'OfflineCreditCard'){
		currentSale.order_payments.push({id: payment_id, amount: parseFloat(amount).toFixed(2), payment_type: "credit_card", transaction_id: data.transid, authorization_id: data.authcode, card_last_four: data.card_last_four, exp_date: data.exp_date});
		clearAlert(null);
		return exitPaymentScreen();
	}
	
	// Post Data
	postData = {api_token: globalCompanyToken, magdata: MagData.toString(), orderId: currentSale.id.toString(), card_number: CardNum.toString(), exp: ExpDate.toString(), cvv: cv2.toString(), name: NameOnCard.toString(), payment_amount: amount.toString(), store_id: globalStoreId, register_id: globalRegisterId};
	$.post("/payment_api3/credit_card_payment.json", postData, function(data) {
		if (data.RespMSG == 'Approved'){
			currentSale.order_payments.push({id: payment_id, amount: parseFloat(amount).toFixed(2), payment_type: "credit_card", transaction_id: data.transid, authorization_id: data.authcode, card_last_four: data.card_last_four, exp_date: data.exp_date});
		}else{
			alert("I'm sorry, I could not process this card \n \nReason:\n" + data.RespMSG)
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
	postData = {api_token: globalCompanyToken, card_number: CardNum.toString(), amount: charge_amount, order_id: currentSale.id, id: payment_id, store_id: globalStoreId};
	$.post("/payment_api3/gift_card_payment.json", postData, function(data) {
		if (data.status == 'Approved'){	
			currentSale.order_payments.push({id: payment_id, amount: parseFloat(data.charged_amount).toFixed(2), payment_type: "gift_card", exp_date: data.exp_date, remaining_balance: parseFloat(data.remaining_balance).toFixed(2), transaction_id: data.transaction_id, gift_card_id : data.gift_card_id})
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
	showPage('#cashRegisterPage');
	$("#cashPaymentBox").show();
	$("#creditCardPaymentBox").hide();
	$("#giftCardPaymentBox").hide();
	$("#checkPaymentBox").hide();	
	$('.payment-data-field').val('');
	cashAmount = null;
	totalOrder();
}

// Suspended Sales ------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

function suspendSale(){
	currentSale.status = 'suspended';
	saveOrder();
	currentSale=null;
	checkStatus();
}

function viewSuspendedSales(){
	orders = dbOrders.find({where: {field: "status", compare: "equals", value: "suspended"}});
	if (orders.length == 0){
		alertCode('noSuspendedSales', 'resetScanBox()');
		return resetScanBox();
	}else{
		all_orders = '';
		for(i=0;i<orders.length;i++){
			line_items = '';
			for (n=0;n<orders[i].order_line_items.length;n++){line_items+="(" + orders[i].order_line_items[n].qty + ")" + orders[i].order_line_items[n].name + "<br>";}
			all_orders += "<tr><td class='row'>" + orders[i].created_at.substr(4, 2) + "/" + orders[i].created_at.substr(6, 2) + "/" + orders[i].created_at.substr(0, 4) + " at " + orders[i].created_at.substr(8, 2) + " : " + orders[i].created_at.substr(10, 2) + "</td><td class='row'>" + orders[i].customer_name + "</td><td class='row'>" + line_items + "</td><td class='row'><input type='button' value='Choose Sale' class='btn btn-go' onclick='selectSuspendedSale(\"" + orders[i].id + "\")'></td></tr>";
		}
		$('#suspendedSaleList').html(all_orders);
		showPage('#suspendedScreen')
	}
}

function selectSuspendedSale(id){
	dbOrders.update({data: {status: 'open'}, where:{field: "id", compare: "equals", value: id}});
	saveOrder();
	currentSale = dbOrders.find({where: {field: "id", compare: "equals", value: id}})[0];
	showPage('#cashRegisterPage');
}

// Cancel Sale # Need to refund payments -------------------------------------------------------------------------------------------------------------------------------------------------------

function cancelSale(){
	for (i=0;i<currentSale.order_payments.length;i++){
		if (currentSale.order_payments[i].payment_type == 'cash'){
			adjustTill(parseFloat(currentSale.order_payments[i].amount)*(-1));
		}
		if (currentSale.order_payments[i].payment_type == 'credit_card'){
			cancelCreditCardPayment(currentSale.order_payments[i], globalStoreId);
		}
		if (currentSale.order_payments[i].payment_type == 'gift_card'){
			cancelGiftCardPayment(currentSale.order_payments[i].gift_card_id, currentSale.order_payments[i].transaction_id);
		}
	}
	dbOrders.remove({where: {field: "status", compare: "equals", value: "open"}});
	currentSale = null;
	saveOrder();
	checkStatus();
}

function cancelGiftCardPayment(gift_card_id, transaction_id){
	postData = {api_token: globalCompanyToken, card_id: gift_card_id, trans_id: transaction_id};
	$.post("/payment_api3/cancelGiftCardPayment.json", postData, function(data) {
		if (data.status != 'ok'){	
			alert("I'm sorry, something went wrong");
			return false;
		}
	}, 'json')
	.error(function() {
		if (navigator.onLine){
			alert("I am having a problem connecting to the payment server. Wait a second then try again.");
		}else{
			alert("I'm sorry, It appears the internet connection is down. I can only refund gift cards when I am online.");
		}
	});
}

function cancelCreditCardPayment(payment, store_id){
	postData = {api_token: globalCompanyToken, magData: '', transaction_id: payment.transaction_id.toString(), refundAmount: payment.amount, storeId: store_id, orderId: '', orderPaymentId: payment.id};
	$.post("/payment_api3/refund_credit_card.json", postData, function(data) {
		console.log(JSON.stringify(data))
	}, 'json')
	.error(function() {
		if (navigator.onLine){
			alert("I am having a problem connecting to the payment server. Wait a second then try again.");
		}else{
			alert("I'm sorry, It appears the internet connection is down. I can only process credit cards when I am online.");
		}
	});
}

// Complete Sale -------------------------------------------------------------------------------------------------------------------------------------------------------


function completeSale(){
	line_items = '', subtotal = 0, credit_card = 0, gift_card = 0, check = 0, cash = 0.00;change=0;
	for (i=0;i<currentSale.order_line_items.length;i++){
		line_items += '<tr><td>( ' + currentSale.order_line_items[i].qty + ' ) ' + currentSale.order_line_items[i].name + '</td><td>' + globalCurrencyCode + parseFloat(currentSale.order_line_items[i].price).toFixed(2) + '</td><td>' + globalCurrencyCode + parseFloat(currentSale.order_line_items[i].total).toFixed(2) + '</td></tr>';
	}
	for (i=0;i<currentSale.order_payments.length;i++){
		if (currentSale.order_payments[i].payment_type == 'cash'){
			cash += parseFloat(currentSale.order_payments[i].amount);
		}
		if (currentSale.order_payments[i].payment_type == 'credit_card'){
			credit_card += parseFloat(currentSale.order_payments[i].amount);
		}
		if (currentSale.order_payments[i].payment_type == 'gift_card'){
			gift_card += parseFloat(currentSale.order_payments[i].amount);
		}
		if (currentSale.order_payments[i].payment_type == 'check'){
			check += parseFloat(currentSale.order_payments[i].amount);
		}
	}
	if(money(currentSale.amount_due)<= -0.01){
		payment_id = (currentSale.id + "P" + currentSale.order_payments.length).toString();
		currentSale.order_payments.push({id: payment_id, amount: money(currentSale.amount_due).toFixed(2), payment_type: "change", transaction_id: payment_id, authorization_id: ""})
		adjustTill(currentSale.amount_due);
	}
	saveOrder();
	$('#innerReceiptProductList').html(line_items);
	$('.receiptSubTotal').html(globalCurrencyCode + money(subtotal).toFixed(2));
	$('.receiptTax').html(currentSale.tax.toFixed(2));
	$('.receiptTotal').html(currentSale.total.toFixed(2));
	
	$('.receiptCash').html(globalCurrencyCode + money(cash).toFixed(2));
	$('.receiptCreditCard').html(globalCurrencyCode + money(credit_card).toFixed(2));
	$('.receiptGiftCard').html(globalCurrencyCode + money(gift_card).toFixed(2));
	$('.receiptCheck').html(globalCurrencyCode + money(check).toFixed(2));
	$('.receiptChange').html(globalCurrencyCode + money(currentSale.amount_due).toFixed(2).replace('-', ''));
	
	$('.companyName').html(globalCompanyName);
	$('.storeAddress').html(globalStoreAddress);
	$('#barcode').html( code128( currentSale.id.toString() ) );
	$('#receiptBarCodeId').html(currentSale.id.toString());
	checkStatus();
	showPage('#receiptScreenPage');
	setTimeout(function(){window.print();}, 200);
	syncOrder(currentSale.id);
	currentSale=null;
}

function syncOrder(order_id){
	order = JSON.stringify(dbOrders.find({where: {field: 'id', compare: 'equals', value: order_id}})[0]);
	$.post("/api3/sync_order.json", {api_token: globalCompanyToken, orderData: JSON.stringify(dbOrders.find({where: {field: 'id', compare: 'equals', value: order_id}})[0])}, function(data) {
		if (data == 'yes'){
			dbOrders.remove({where: {field: "id", compare: "equals", value: order_id}});
		}else{
			dbOrders.update({data: {status: 'completedoffline'}, where: {field: 'id', compare: 'equals', value: order_id}});
		}
	}, 'text')
	.error(function() {
		dbOrders.update({data: {status: 'completedoffline'}, where: {field: 'id', compare: 'equals', value: order_id}});
	})
	.complete(function(){localStorage.setItem('dbOrders', JSON.stringify(dbOrders.find()));});
}




//
// Timesheet
//	

function punchTimeCard(){
	timeSheetArea = document.querySelector('#timeSheetInfoArea');
	timeSheetArea.innerHTML = '<div class="innerTimesheetArea"><h1>Loading...</h1>One moment, we are contacting the servers</div>';
	timeSheetArea.style.display='block';
	usernameInput = document.querySelector('#timeclockUsername');
	passwordInput = document.querySelector('#timeclockPassword');
	postData = {api_token: globalCompanyToken, time: getTimeString('no').toString(), store_id: globalStoreId, username: usernameInput.value, password: passwordInput.value};
	console.log(postData);
	$.post("/api3/punchClock.json", postData, function(data) {
		if (data.status == 'success'){	
			timeSheetArea.innerHTML = '<div class="innerTimesheetArea"><h1 style="color:#7bc231;">' + data.employee_name + '</h1>You have been successfully <b>Clocked ' + data.clock + '</b></div>';
		}else{
			timeSheetArea.innerHTML = '<div class="innerTimesheetArea"><h1 style="color:#ac0000;">OOPS...</h1>You have not been clocked in. Check your username and password and try again.</b></div>';
		}
	}, 'json')
	.error(function() {
		if (navigator.onLine){
			alert("I am having a problem connecting to the payment server. Wait a second then try again.");
		}else{
			alert("I'm sorry, It appears the internet connection is down. I can only process credit cards when I am online.");
		}
		saveData = {time: getTimeString('no').toString(), username: document.querySelector('#timeclockUsername').value};
		dbTimesheets.insert([saveData]);
		localStorage.setItem('dbTimesheets', JSON.stringify(dbTimesheets.find()));
		dbTimesheets.commit();
	})
	.complete(function() {
		usernameInput.value = '';
		passwordInput.value = '';
	});

}


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// Return Section

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	// Views and Displays
	
	
	function returnPage(){
		if(dbOrderReturns.find({where: {field: 'status', compare: 'equals', value: 'open'}})[0]){
			if(!currentReturn){
				currentReturn = newReturn();
			}
			$('#no_return').hide();
			$('#current_return').show();
			displayOrderReturn();
		}else{
			$('#no_return').show();
			$('#current_return').hide();
			$('.origionalLineItems').html('');
			$('.return_line_items').html('');
			$('#return_item_count').html('0');
			$('#returnSubtotal').html('0.00');
			$('#returnTax').html('0.00');
			$('#returnTotal').html('0.00');
			$('#returnDue').html('0.00');
			returnFocusCheck();
		}
	}

	function returnFocusCheck(){
		$('#returnScanField').val('').focus();
		$('#returnQty').val('1');
	}
	
	function displayOrderReturn(){
		// Reset Register if current return ! exist
		if(!currentReturn){
			return returnPage();
		}
		// Display Return
		return_items = '<tr style="background-color:#eeeeee;"><td class="line_heading"><strong>PRODUCT NAME:</strong></td><td class="line_heading" width="110"><strong>PRICE:</strong></td><td class="line_heading" width="95">&nbsp;</td></tr>';
		for(i=0;i<currentReturn.order_return_line_items.length;i++){
			return_items += "<tr><td class='row'><strong>"+ currentReturn.order_return_line_items[i].name +"</strong></td><td class='row' width='110'><strong>$"+ parseFloat(currentReturn.order_return_line_items[i].price).toFixed(2) +"</strong></td><td class='row' width='95'><a class='btn btn-danger' onClick='removeReturnItem(\"" + currentReturn.id + "\", \""+ currentReturn.order_return_line_items[i].product_id +"\" )' >Remove</a></td></tr>";
		}
		$('.return_line_items').html(return_items);
		$('.return-item-count').html(currentReturn.item_count);
		$('.return-subtotal').html(displayMoney(currentReturn.subtotal));
		$('.return-tax').html(displayMoney(currentReturn.tax));
		$('.return-total').html(displayMoney(currentReturn.total));
		$('.return-due').html(displayMoney(currentReturn.amount_owed));
		$('#returnPaymentRightAmount').html(displayMoney(currentReturn.amount_owed));
		$('#returnAmountField').val(displayMoney(currentReturn.amount_owed));
		$('.return-remaining').val(money(currentReturn.amount_owed));
		if (currentReturn.order_id){
			$('.origionalLineItemsWrapper').show();
			displayOrderedItems();
		}else{
			$('.origionalLineItemsWrapper').hide();
		}
		if (currentReturn.order_return_payments.length >= 1){
			$('#cancelReturnButton').hide();
		}else{
			$('#cancelReturnButton').show();
		}
		if(currentReturn.amount_owed.toFixed(2) === '0.00'){
			$('#RightReturnPaymentButton').hide();
			$('#RightReturnCompleteButton').show();
		}else{
			$('#RightReturnPaymentButton').show();
			$('#RightReturnCompleteButton').hide();
		}
		returnFocusCheck();
	}
	
	

	// Add Items To Return

	function addToReturn(query, qty){
		if(!query){
			query = $('#returnScanField').val();
			qty = $('#returnQty').val();
		}
		if(!query){
			returnFocusCheck();
			return false;
		}
		result = dbProducts.find({where: {join: "or", terms: [{field: "product_id", compare: "equals", value: query.toString()},{field: "upc", compare: "equals", value: query.toString()},{field: "sku", compare: "equals", value: query.toString()},{field: "ean", compare: "equals", value: query.toString()},{field: "m_sku", compare: "equals", value: query.toString()}]} })[0];
		if(result){
			addItemToReturn(result.product_id, qty);
		}else{
			if(query.slice(-1) == 'R'){
				returnGetOrder(query);
			}
			else{
				returnFocusCheck();
				return alert('Product/Order Not Found')
			}
		}
	}

	function addItemToReturn(product_id, qty){
		product = dbProducts.find({where: {field: "product_id", compare: "equals", value: product_id}})[0];
		purchasedItem = null;
		if(!currentReturn){
			currentReturn = newReturn();
		}
		for (n = 0; n < parseInt(qty); n++){
			// See if this item was on the receipt
			for (i=0;i<currentReturn.purchased_items.length;i++){
				if (currentReturn.purchased_items[i].product_id == product_id) {
					purchasedItem = currentReturn.purchased_items[i];
				};
			}
			// If it was on the receipt, use the receipt price for the same qty returned
			if (purchasedItem){
				count = 0;
				for (i=0;i<currentReturn.order_return_line_items.length;i++){
					if(currentReturn.order_return_line_items[i].product_id == product_id){
						count++;
					}
				}
				if (count >= purchasedItem.qty){
					new_price = parseFloat(product.return_price);
				}else{
					new_price = purchasedItem.price
				}
			}else{
				new_price = parseFloat(product.return_price);
			}
			if (new_price == 0.00){
				new_price = parseFloat(product.price);
			}
			currentReturn.order_return_line_items.push({id: parseInt(currentReturn.order_return_line_items.length)+parseInt(1), name: product.name, product_id: product.product_id, price: new_price, nontax: product.nontax});
		}
		totalReturn();
		returnPage();
	}
	
	
	function totalReturn(){
		rsubtotal=0.00;rtax=0.00;
		for(i=0;i<currentReturn.order_return_line_items.length;i++){
			rsubtotal+=money(currentReturn.order_return_line_items[i].price);
			if(currentReturn.order_return_line_items[i].nontax != 1){
				rtax+=money(money(currentReturn.order_return_line_items[i].price)*currentReturn.tax_rate);
			}
		}
		currentReturn.item_count = currentReturn.order_return_line_items.length;
		currentReturn.subtotal = rsubtotal;
		currentReturn.tax = rtax;
		currentReturn.total = money(rsubtotal)+money(rtax);
		amount_owed=currentReturn.total;tax_refunded=0.00;total_refunded=0.00;
		for(i=0;i<currentReturn.order_return_payments.length;i++){
			amount_owed-=money(currentReturn.order_return_payments[i].amount);
			tax_refunded+=money(currentReturn.order_return_payments[i].amount*currentReturn.tax_rate);
			total_refunded+=money(currentReturn.order_return_payments[i].amount);
		}
		currentReturn.amount_owed=money(amount_owed);
		currentReturn.tax_refunded=money(tax_refunded);
		currentReturn.total_refunded=money(total_refunded);
		saveReturn();
	}
	

	function returnGetOrder(id){
		$.post("/api3/returnGetOrder.json", {api_token: globalCompanyToken, order_id: id}, function(data) {
			if (data){
				if(!currentReturn){
					currentReturn = newReturn();
				}
				currentReturn.purchased_items = data.order_line_items;
				currentReturn.order_id = data.id;
				currentReturn.tax_rate = data.tax_rate;
				currentReturn.order_payments = data.order_payments;
				console.log(currentReturn);
				totalReturn();
				returnPage();
			}else{
				returnFocusCheck();
				return alert('Item/Sale not found');
			}
		}, 'json')
	}

	function displayOrderedItems(){
		line_items_html = '<tr class="headingOLI"><td>Product</td><td>Price</td><td>QTY</td><td>Add to Return</td></tr>';
		for(i=0;i<currentReturn.purchased_items.length;i++){
			line_items_html += '<tr><td>' + currentReturn.purchased_items[i].name + '</td><td>' + globalCurrencyCode + money(currentReturn.purchased_items[i].price).toFixed(2) + '</td><td>' + currentReturn.purchased_items[i].qty + '</td><td><input type="button" value="+ Add" class="btn btn-go btn-sm" onclick="addItemToReturn(\'' + currentReturn.purchased_items[i].product_id + '\', \'1\', \'' + currentReturn.purchased_items[i].price + '\')"></td></tr>';
		}
		$('.origionalLineItems').html(line_items_html);
	}
	
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

	function removeReturnItem(return_id, product_id){
		array = currentReturn.order_return_line_items.sort(predicatBy("price", 1));
		count = 0;
		new_items = [];
		for (i=0; i < currentReturn.order_return_line_items.length; i++){
			if (currentReturn.order_return_line_items[i].product_id === product_id && count === 0){
				count++;
			}else{
				new_items.push({id: parseInt(new_items.length)+parseInt(1), name: currentReturn.order_return_line_items[i].name, product_id: currentReturn.order_return_line_items[i].product_id, price: currentReturn.order_return_line_items[i].price, nontax: currentReturn.order_return_line_items[i].nontax});
			}
		}
		currentReturn.order_return_line_items = new_items;
		totalReturn();
		returnPage();
	}


	// Return Payment Screen
	
	function returnPaymentScreen(){
		// Detect if a Credit Card Was Used
		cardFound = null;
		for(i=0;i<currentReturn.order_payments.length;i++){
			if (currentReturn.order_payments[i].payment_type == 'credit_card'){
				cardFound = true;
			}
		}
		if(cardFound){
			$('#returnCreditCardButton').show();
			showReturnPaymentMethod('credit_card');
		}else{
			$('#returnCreditCardButton').hide();
		}
		showPage('#returnsPaymentPage');
	}
	
	function addReturnCashAmmount(amount){
		cashAmount+=money(amount)
		$('#returnAmountField').val(cashAmount.toFixed(2));
	}
	
	function showReturnPaymentMethod(method){
		if (method == 'cash'){
			$('#cashReturnPayment').show();
			$('#creditReturnPayment').hide();
		}
		if (method == 'credit_card'){
			$('#cashReturnPayment').hide();
			$('#creditReturnPayment').show();
			cardsHtml = '';
			for(i=0;i<currentReturn.order_payments.length;i++){
				if (currentReturn.order_payments[i].payment_type == 'credit_card'){
					cardsHtml+='<div class="returnCreditPaymentCard" id="card' + currentReturn.order_payments[i].id + '"><h3>Original Amount: ' + globalCurrencyCode + currentReturn.order_payments[i].amount + '</h3>Card Number: **** **** **** ' + currentReturn.order_payments[i].card_last_four + '<br><input type="button" value="Refund Card " onclick="selectReturnCreditCard(\'' + currentReturn.order_payments[i].id + '\')" class="buttons"></div>';
				}
			}
			document.querySelector('.returnCreditPaymentLeft').innerHTML = cardsHtml;
		}
	}
	
	function selectReturnCreditCard(id){
		// find the payment
		for(i=0;i<currentReturn.order_payments.length;i++){
			if(currentReturn.order_payments[i].id.toString() === id.toString()){
				payment = currentReturn.order_payments[i];
			}
		}
		// If payment found, refund it
		if(payment){
			ProcessingAlert('processingReturnPayment');
			postData = {api_token: globalCompanyToken, orderId: currentReturn.order_id, refundAmount: currentReturn.amount_owed, storeId: globalStoreId, orderPaymentId: payment.id};
				$.post("/payment_api3/refund_credit_card.json", postData, function(data) {
					console.log(JSON.stringify(data));
					if (data.RespMSG == 'Approved'){
						addPaymentToReturn(data.amount, 'credit_card', 'complete', data.card_last_four, data.transaction_id, data.authcode)
					}else{
						alert("I'm sorry, I could not refund this card \n \nReason:\n" + data.RespMSG)
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
				});
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
	
	function addPaymentToReturn(paymentAmount, paymentType, paymentStatus, ccLastFour, TransactionId, AuthCode){
		currentReturn.order_return_payments.push({
			id: currentReturn.id + "RP" + currentReturn.order_return_payments.length,
		  	amount: paymentAmount,
		  	payment_type: paymentType,
		  	status: paymentStatus,
		  	card_last_four: ccLastFour,
		  	transaction_id: TransactionId,
		  	authorization_id: AuthCode
		});
		totalReturn();
		returnPage();
		showPage('#returnsPage');
		if (paymentType == 'cash'){adjustTill(parseFloat(paymentAmount)*(-1));}
	}



	function cancelReturn(){
		dbOrderReturns.remove({where: {field: "status", compare: "equals", value: "open"}});
		localStorage.setItem('dbOrderReturns', JSON.stringify(dbOrderReturns.find()));
		dbOrderReturns.commit();
		currentReturn=null;
		returnPage();
	}




	// Sync Return
	
	function completeReturn(){
		line_items = '', taxable = 0, subtotal = 0, credit_card = 0, gift_card = 0, cash = 0.00;
		if (currentReturn.order_return_line_items.length == 0){
			dbOrderReturns.remove({where: {field: "status", compare: "equals", value: 'open'}});
			saveReturn();
			return returnPage();
		}
		// Line Items
		for (i=0; i<currentReturn.order_return_line_items.length; i++){
			line_items += '<tr><td>' + currentReturn.order_return_line_items[i].name + '</td><td>' + globalCurrencyCode + money(currentReturn.order_return_line_items[i].price).toFixed(2) + '</td></tr>';
			subtotal += parseFloat(currentReturn.order_return_line_items[i].price);
			if (currentReturn.order_return_line_items[i].nontax == 0){
				taxable += parseFloat(currentReturn.order_return_line_items[i].price);
			}
		}
		// Totals
		for (i=0; i<currentReturn.order_return_payments.length; i++){
			if (currentReturn.order_return_payments[i].payment_type == 'cash'){
				cash += parseFloat(currentReturn.order_return_payments[i].amount);
			}
			if (currentReturn.order_return_payments[i].payment_type == 'credit_card'){
				credit_card += parseFloat(currentReturn.order_return_payments[i].amount);
			}
			if (currentReturn.order_return_payments[i].payment_type == 'gift_card'){
				gift_card += parseFloat(currentReturn.order_return_payments[i].amount);
			}
		}
		// Display Receipt
		$('.returnReceiptSubTotal').html(displayMoney(currentReturn.subtotal));
		$('.returnReceiptTax').html(displayMoney(currentReturn.tax));
		$('.returnReceiptTotal').html(displayMoney(currentReturn.total));
		
		$('.returnReceiptCash').html(displayMoney(cash));
		$('.returnReceiptCreditCard').html(displayMoney(credit_card));
		$('.returnReceiptGiftCard').html(displayMoney(gift_card));
		
		$('#innerReturnReceiptProductList').html(line_items);
		$('.companyNameReturn').html(globalCompanyName);
		$('.storeAddressReturn').html(globalStoreAddress.replace('&lt;BR&gt;', '<br>'));
		
		$("#returnbarcode").html(code128(currentReturn.id));
		$("#returnReceiptBarCodeId").html(currentReturn.id);
		
		saveReturn();
		showPage('#returnReceiptScreenPage');
		setTimeout(function(){window.print();syncOrderReturn(currentReturn.id);currentReturn = null;}, 200);
	}
	
	function syncOrderReturn(order_return_id){
		$.post("/api3/sync_return.json",  {api_token: globalCompanyToken, returnData: JSON.stringify(dbOrderReturns.find({where: {field: 'id', compare: 'equals', value: order_return_id}})[0])}, function(data) {
			if (data.status == 'success'){
				dbOrderReturns.remove({where: {field: 'id', compare: 'equals', value: order_return_id}});
			}else{
				dbOrderReturns.update({data: {status: 'completedoffline'}, where: {field: 'id', compare: 'equals', value: order_return_id}});
			}
		})
		.error(function() {
			dbOrderReturns.update({data: {status: 'completedoffline'}, where: {field: 'id', compare: 'equals', value: order_return_id}});
		})
		.complete(function(){
			localStorage.setItem('dbOrderReturns', JSON.stringify(dbOrderReturns.find()));
			dbOrderReturns.commit();
		});
	}
	

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// Options

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	function addCashToRegister(){
		console.log('addCashToRegister');
		postData = {api_token: globalCompanyToken, register_id: globalRegisterId, timestamp: getTimeString('no').toString(), employee_id: globalEmployeeId, employee_name: globalEmployeeName, amount: money($('#addition_amount').val())};
		console.log(postData);
		
		$.post("/api3/addCashToRegister.json", postData, function(data) {
			if(data.status!='ok'){
				dbTills.insert([ {till_type: 'add', time: getTimeString('no').toString(), register_id: globalRegisterId, employee_id: globalEmployeeId, employee_name: globalEmployeeName, amount: money($('#addition_amount').val())} ]);
			}
		}, 'json').complete(function(){
			adjustTill(parseFloat($('#addition_amount').val()));
			alert('Added ' + globalCurrencyCode + $('#addition_amount').val() + ' to the till.');
			$('#addition_amount').val('')
		});
	}

	function removeCashFromRegister(){
		postData = {company_id: localStorage.getItem('company_id'), register_id: localStorage.getItem('register_id'), employee_id: localStorage.getItem('employee_id'), employee_name: localStorage.getItem('employee_name'), amount: document.querySelector('#withdraw_amount').value, 'authenticity_token': $('meta[name="csrf-token"]').attr('content')};
		$.post("/sync/removeCashFromRegister.json", postData, function(data) {
			localStorage.setItem('till', data.new_till);
			alert('Removed ' + document.querySelector('#withdraw_amount').value + ' from the till.');
		}, 'json').error(function() {
			if (navigator.onLine){
				alert("I am having a problem connecting to the cloud. Wait a second then try again.");
			}else{
				alert("I'm sorry, It appears the internet connection is down. I can only remove funds when I am online.");
			}

		}).complete(function(){
			document.querySelector('#withdraw_amount').value = '';
		});
	}

		// Verify Till >> 0 = audit, 1 = close, 2 = open
		var tillVerify = 0;
		function auditTill(){
			$('#optionsWrapper').hide();
			$('#auditTillWrapper').show();
			tillVerify = 0;
			updateVerifyTill();
		}
	
		function closeRegister(){
			$('#optionsWrapper').hide();
			$('#auditTillWrapper').show();
			tillVerify = 1;
			updateVerifyTill();
		}
		
		function openRegister(){
			showPage('#optionsPage');
			$('#optionsWrapper').hide();
			$('#auditTillWrapper').show();
			tillVerify = 2;
			updateVerifyTill();
		}
	
		function updateVerifyTill(){
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
			$("#auditTillWrapper input").keyup(function(){
				total = 0;
				// Loose Change
				total += parseInt(document.querySelector('#qty_item_a').value)*0.01 || 0; // pennies
				total += parseInt(document.querySelector('#qty_item_b').value)*0.05 || 0; // nickels
				total += parseInt(document.querySelector('#qty_item_c').value)*0.10 || 0; // dimes
				total += parseInt(document.querySelector('#qty_item_d').value)*0.25 || 0; // quarters
				// Change Rolls
				total += parseInt(document.querySelector('#qty_item_ar').value)*0.50 || 0; // penny rolls
				total += parseInt(document.querySelector('#qty_item_br').value)*1.00 || 0; // nickel rolls
				total += parseInt(document.querySelector('#qty_item_cr').value)*5.00 || 0; // dime rolls
				total += parseInt(document.querySelector('#qty_item_dr').value)*10.00 || 0; // quarter rolls
				// Dolalrs
				total += parseInt(document.querySelector('#qty_item_1').value)*1.00 || 0; // ones
				total += parseInt(document.querySelector('#qty_item_2').value)*5.00 || 0; // Fives
				total += parseInt(document.querySelector('#qty_item_3').value)*10.00 || 0; // Tens
				total += parseInt(document.querySelector('#qty_item_4').value)*20.00 || 0; // Twenties
				total += parseInt(document.querySelector('#qty_item_5').value)*50.00 || 0; // Fifties
				total += parseInt(document.querySelector('#qty_item_6').value)*100.00 || 0; // Hundreds
				document.querySelector('#verify_till_amount').value = total.toFixed(2);
			})
		}
	
		function submitTillVerification(){
			postData = {api_token: globalCompanyToken, register_id: globalRegisterId, employee_id: globalEmployeeId, employee_name: globalEmployeeName, amount: $('#verify_till_amount').val(), verificationMethod: tillVerify, timestamp: getTimeString('no').toString()};
			$.post("/api3/submitTillVerification.json", postData, function(data) {
				localStorage.setItem('till', data.new_till);
				alert('Reported ' + document.querySelector('#verify_till_amount').value + ' in the till.');
				$('#optionsWrapper').show();
				$('#auditTillWrapper').hide();
				if (tillVerify == 1){
					globalRegisterId = null;
					localStorage.setItem('register_name', '');
					localStorage.setItem('register_id', '');
					checkLogin();
				}
				if (tillVerify == 2){
					localStorage.setItem('till', $('#verify_till_amount').val());
					localStorage.setItem('register_status', '1');
					showPage('#cashRegisterPage');
				}
			}, 'json').error(function() {
				alert("I'm sorry, It appears the internet connection is down. I can only verify tills / close registers when I am online.");
			}).complete(function(){
				document.querySelector('#verify_till_amount').value = '';
				$('#qty_item_a').val('0');$('#qty_item_b').val('0');$('#qty_item_c').val('0');$('#qty_item_d').val('0');
				$('#qty_item_ar').val('0');$('#qty_item_br').val('0');$('#qty_item_cr').val('0');$('#qty_item_dr').val('0');
				$('#qty_item_1').val('0');$('#qty_item_2').val('0');$('#qty_item_3').val('0');$('#qty_item_4').val('0');$('#qty_item_5').val('0');$('#qty_item_6').val('0');
				if (tillVerify == 1){
					for (i=0;i<globalRegisters.length;i++){
						if(globalRegisters[i].id == globalRegisterId){
							globalRegisters[i].status = 0;
						}
					}
					localStorage.setItem('all_registers', JSON.stringify(globalRegisters));
				}
					
			});
		}
	
		// changeUser
	
		function changeUser(){
			localStorage.setItem('employee_id', '');localStorage.setItem('employee_name', '');
			checkLogin();
		}
		
		
		// Log Off User
		
		function logOffEmployee(){
			postData = {api_token: globalCompanyToken, register_id: globalRegisterId};
			$.post("/api3/logOffEmployee.json", postData, function(data) {}, 'json').error(function() {}).complete(function(){
				globalEmployeeId = null;globalEmployeeName = null;localStorage.setItem('employee_id', '');localStorage.setItem('employee_name', '');
				
			}).complete(function(){checkLogin();});
		}
		
		// Logg Of Register
		
		function loggOffRegister(){
			globalRegisterId=null;globalRegisterName=null;localStorage.setItem('register_id', '');localStorage.setItem('register_name', '');
			checkLogin();
		}
		
		function logOffStore(){
			globalStoreId=null;localStorage.setItem('store_id', '');
			globalStoreName=null;localStorage.setItem('store_name', '');
			localStorage.setItem('store_address', '');
            globalStoreAddress = null;;
            globalTaxRate = null;localStorage.setItem('tax_rate', '');
			globalGateway = null;
			loggOffRegister();
		}

		
		// Clear Register Data
		
		function clearRegisterData(){
			localStorage.setItem('dbProducts', '[]');
			localStorage.setItem('dbOrderReturns', '[]');
			localStorage.setItem('dbTimesheets', '[]');
			localStorage.setItem('dbCoupons', '[]');
			localStorage.setItem('dbTills', '[]');
			currentSale=null;
			currentReturn=null;
			pages=null;
			itemButtons=null;
			currentPage=null;
			globalCompanyToken=null; localStorage.setItem('company_token', '');
			globalCompanyID=null; localStorage.setItem('company_id', '');
			globalCompanyName=null; localStorage.setItem('company_name', '');
			globalEmployeeId=null; localStorage.setItem('employee_id', '');
			globalEmployeeName=null; localStorage.setItem('employee_name', '');
			globalRegisterId=null; localStorage.setItem('register_id', '');
			globalRegisterName=null; localStorage.setItem('register_name', '');
			globalStoreAddress=null; localStorage.setItem('store_address', '');
			globalStoreId=null; localStorage.setItem('store_id', '');
			globalStoreName=null; localStorage.setItem('store_name', '');
			globalGateway=null; localStorage.setItem('store_gateway', '');
			globalTaxRate=null; localStorage.setItem('tax_rate', '');
			globalStores=null; localStorage.setItem('all_stores', '');
			globalRegisters=null; localStorage.setItem('all_registers', '');
			globalCurrencyCode = null; localStorage.setItem('currency_code', '');
			localStorage.setItem('currentPage', '');
			localStorage.setItem('register_status', '');
			localStorage.setItem('till', '');
			displayLogin();
		}


//
// Barcode Generation
//

BARS = [212222,222122,222221,121223,121322,131222,122213,122312,132212,221213,221312,231212,112232,122132,122231,113222,123122,123221,223211,221132,221231,213212,223112,312131,311222,321122,321221,312212,322112,322211,212123,212321,232121,111323,131123,131321,112313,132113,132311,211313,231113,231311,112133,112331,132131,113123,113321,133121,313121,211331,231131,213113,213311,213131,311123,311321,331121,312113,312311,332111,314111,221411,431111,111224,111422,121124,121421,141122,141221,112214,112412,122114,122411,142112,142211,241211,221114,413111,241112,134111,111242,121142,121241,114212,124112,124211,411212,421112,421211,212141,214121,412121,111143,111341,131141,114113,114311,411113,411311,113141,114131,311141,411131,211412,211214,211232,23311120];
START_BASE = 38
STOP = 106 //BARS[STOP]==23311120 (manually added a zero at the end)

var fromType128 = {
    A: function(charCode) {
        if (charCode>=0 && charCode<32)
            return charCode+64;
        if (charCode>=32 && charCode<96)
            return charCode-32;
        return charCode;
    },
    B: function(charCode) {
        if (charCode>=32 && charCode<128)
            return charCode-32;
        return charCode;
    },
    C: function(charCode) {
        return charCode;
    }
};

function code128(code, barcodeType) {
    if (arguments.length<2)
        barcodeType = code128Detect(code);
    if (barcodeType=='C' && code.length%2==1)
        code = '0'+code;
    var a = parseBarcode128(code,  barcodeType);
    return bar2html128(a.join('')) ;//+ '<label>' + code + '</label>';
}


function code128Detect(code) {
    if (/^[0-9]+$/.test(code)) return 'C';
    if (/[a-z]/.test(code)) return 'B';
    return 'A';
}

function parseBarcode128(barcode, barcodeType) {
    var bars = [];
    bars.add = function(nr) {
        var nrCode = BARS[nr];
        this.check = this.length==0 ? nr : this.check + nr*this.length;
        this.push( nrCode || format("UNDEFINED: %1->%2", nr, nrCode) );
    };

    bars.add(START_BASE + barcodeType.charCodeAt(0));
    for(var i=0; i<barcode.length; i++)
    {
        var code = barcodeType=='C' ? +barcode.substr(i++, 2) : barcode.charCodeAt(i);
        converted = fromType128[barcodeType](code);
        if (isNaN(converted) || converted<0 || converted>106)
            throw new Error(format("Unrecognized character (%1) at position %2 in code '%3'.", code, i, barcode));
        bars.add( converted );
    }
    bars.push(BARS[bars.check % 103], BARS[STOP]);

    return bars;
}

function format(c){
    var d=arguments;
    var e= new RegExp("%([1-"+(arguments.length-1)+"])","g");
    return(c+"").replace(e,function(a,b){return d[b]})
}

function bar2html128(s) {
    for(var pos=0, sb=[]; pos<s.length; pos+=2)
    {
        sb.push('<div class="bar' + s.charAt(pos) + ' space' + s.charAt(pos+1) + '"></div>');
    }
    return sb.join('');
}
;
