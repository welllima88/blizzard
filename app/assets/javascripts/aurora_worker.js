self.addEventListener('message', function(e) {
	
	// Data
	data = e.data;
	
	// Commands
	switch (data.cmd){
		
		// Display Stores
		case 'display_stores':
			
			stores = data.store_data;
			store_html = '';
			
			for( i=0; i<stores.length; i++ ){
				store_html += '<div class="col-xs-12 col-sm-6 col-md-4 col-lg-3 store-box"><h4>' + stores[i].name + '</h4><p>' + stores[i].address + '<br>' + stores[i].city + ', ' + stores[i].state + ' ' + stores[i].zip + '</p><input type="button" value="Select Store" class="btn btn-primary btn-lg" onclick="selectStore(\''+stores[i].id+'\')" /></div>';
			}
			
			if( stores.length == 0 ){
				store_html = '<div class="row"><div class="col-sm-12 text-center" style="background-color:#eee;padding:10px;"><h3 style="margin:0;padding:0;">You must add a store profile in the <a href="/admin">admin section</a> before you can use Evendra.</h3></div></div>';
			}
			
			self.postMessage( {'cmd': 'display_stores', 'content': store_html} );
			
		break;
		
		// display_registers
		case 'display_registers':
			store_id = data.store_id;
			registers = data.register_data;
			
			open_register_html = '';
			closed_register_html = '';
			
			for( i=0; i<registers.length; i++ ){
				// Only show registers associated with our store
				if( registers[i].store_id == store_id ){
					
					if( registers[i].current_employee ){ current_user = '<b>CURRENT USER:</b> ' + registers[i].current_employee; }else{ current_user = ''; }
					
					if( registers[i].status == 0 ){
						closed_register_html += '<div class="col-xs-12 col-sm-6 col-md-4 col-lg-3 store-box closed"><h4>' + registers[i].name + '</h4><p>Status: Closed<p><input type="button" value="Open Register" class="btn btn-primary btn-lg" onclick="selectRegister(\'' + registers[i].id + '\')" /></div>';
					}else{
						open_register_html += '<div class="col-xs-12 col-sm-6 col-md-4 col-lg-3 store-box opened"><h4>' + registers[i].name + '</h4><p><b>Status:</b> Open</p>' + current_user + '<br><br><input type="button" value="Select Register" class="btn btn-primary btn-lg" onclick="selectRegister(\'' + registers[i].id + '\')" /></div>';
					}
				}				
			}
			
			self.postMessage( {'cmd': 'display_registers', 'closed_register_html': closed_register_html, 'open_register_html': open_register_html } );
			
		break;
		
	}
	
	function dedup(array){
		clean_array = [];
		for(i=0;i<array.length;i++){ if(clean_array.indexOf(array[i]) === -1) clean_array.push(array[i]); }
		return clean_array;
	}
	
	function compare_newest_first(a,b) {
	  if (a.created_at_number > b.created_at_number)
	     return -1;
	  if (a.created_at_number < b.created_at_number)
	    return 1;
	  return 0;
	}
  
}, false);