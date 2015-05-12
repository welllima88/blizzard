//
// Orders Module
//

// Current Sale Models
var current_sale = null;
if( localStorage.getItem('current_sale') != '' ){ current_sale = JSON.parse(localStorage.getItem('current_sale')); }
function saleModel() {
	
		timestring = new Date()*1;
		this._id = current_register.id + timestring + 'R',
		this.id = current_register.id + timestring + 'R',
		this.company_id = current_company.id,
		this.status = 'open',
		this.created_at = timestring,
		this.completed_at = '',
		this.item_count = 0,
		this.subtotal = 0,
		this.tax_rate = current_store.tax_rate,
		this.tax = 0,
		this.discount = 0,
		this.total = 0,
		this.net_profit = 0,
		this.tip = 0,
		this.amount_due = 0,
		this.coupon_ids = [],
		this.store_id = current_store.id,
		this.store_name = current_store.name,
		this.register_id = current_register.id,
		this.register_name = current_register.name,
		this.customer_id = '',
		this.customer_name = '',
		this.employee_id = current_user.id, 
		this.employee_name = current_user.first_name + ' ' + current_user.last_name,
		this.order_line_items = [],
		this.order_payments = []
	
}

orderModel = {
	
	saveCurrentOrder: function(){
		if( dbOrders.find({where: {field: "_id", compare: "equals", value: current_sale.id}})[0] != null ){
			dbOrders.update({data: current_sale, where:{field: "_id", compare: "equals", value: current_sale.id}});
		}else{
			dbOrders.insert([current_sale]);
		}
		this.save();
	},
	
	save: function(){
		localStorage.setItem( 'dbOrders', JSON.stringify(dbOrders.find()) );
	},
	
	get_current_order: function(){
		return dbOrders.find({where: {field: "status", compare: "equals", value: "open"}})[0];
	},
	
	suspendedSales: function(){
		return dbOrders.find({where: {field: "status", compare: "equals", value: "suspended"}});
	},
	
	openSuspendedSale: function(id){
		dbOrders.update({data: {status: 'open'}, where:{field: "_id", compare: "equals", value: id}});
		return dbOrders.find({where: {field: "_id", compare: "equals", value: id}})[0];
	},
	
	delete_sale: function(id){
		dbOrders.remove({where: {field: "_id", compare: "equals", value: id}});
		this.save();
	}
	
}
;
