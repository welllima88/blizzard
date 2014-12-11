function lightbox(code, callback){
	document.querySelector('#alertContent').innerHTML = code;
	$('#alertBoxBg').fadeIn(150);
	$('#alertBox').fadeIn(300);
	// Close
	$('#alertBoxBg').click(function(){
		clearAlert(callback);
	});
	$('#closeAlert').click(function(){
		clearAlert(callback);
	});
}

function clearAlert(callback){
	$('#alertBoxBg').fadeOut(150);
	$('#alertBox').fadeOut(300, function(){
		document.querySelector('#alertContent').innerHTML = '';
	});
	$('#processingAlert').fadeOut(300);
	if (callback != null){
		eval(callback);
	}
}

function alertCode(code, callback){
	if (code == 'noSuspendedSales'){
		return lightbox('<center>No suspended sales were found.</center>', callback);
	}
	if (code == 'productNotFound'){
		return lightbox('<center>Product not found.</center>', callback);
	}
	if (code == 'enterCustomerPhone'){
		return lightbox('<center>Please enter a customers phone number or email address to search.</center>', callback);
	}
	if (code == 'customerNotFound'){
		return lightbox('<center>Customer Not Found</center>', callback);
	}
	if (code == 'connectionError'){
		return lightbox('<center>There is a problem contacting the cloud, Please check your internet connection.</center>', callback);
	}
	if (code == 'errorAddingCustomer'){
		return lightbox('<center>There was an error while adding this customer to the database.</center>', callback);
	}
}

function orderPaymentPopup(){
	
}

// Processing Popup

function ProcessingAlert(code){
	$('#alertBoxBg').fadeIn(0);
	$('#processingAlert').fadeIn(300);
}
;
