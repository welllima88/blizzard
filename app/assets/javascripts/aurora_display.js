aurora_worker.addEventListener('message', function(e) { 
	
	// Get Data
		data = e.data;
	
	// Display Stores
		if(data.cmd == 'display_stores'){ document.getElementById('store-data').innerHTML = data.content; }
		
	// Display Registers
		if(data.cmd == 'display_registers'){ document.getElementById('registerClosedData').innerHTML = data.closed_register_html; document.getElementById('registerOpenData').innerHTML = data.open_register_html; }
		
 }, false);