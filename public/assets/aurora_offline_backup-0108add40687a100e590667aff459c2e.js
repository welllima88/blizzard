function save_offline( data, type ){
	
	// Configure Data
	var configured_data = { data_type: type, data: data };
	
	// Load offline data
	offline_backup.push( configured_data );
	
	// Save to local storage
	localStorage.setItem( 'offline_backup', JSON.stringify(offline_backup) );
	
}
;
