// Create The Databases on load

var dbProducts = JSORM.db.db({parser: JSORM.db.parser.object()});
var dbOrders = JSORM.db.db({parser: JSORM.db.parser.object(), data: JSON.parse(localStorage.getItem('dbOrders'))});
var dbOrderReturns = JSORM.db.db({parser: JSORM.db.parser.object(), data: JSON.parse(localStorage.getItem('dbOrderReturns'))});
var dbTimesheets = JSORM.db.db({parser: JSORM.db.parser.object(), data: JSON.parse(localStorage.getItem('dbTimesheets'))});
var dbCoupons = JSORM.db.db({parser: JSORM.db.parser.object(), data: JSON.parse(localStorage.getItem('dbCoupons'))});
var dbTills = JSORM.db.db({parser: JSORM.db.parser.object(), data: JSON.parse(localStorage.getItem('dbTills'))});
if(localStorage.getItem('dbProducts') == null){localStorage.setItem('dbProducts', '[]');}
if(localStorage.getItem('dbOrders') == null){localStorage.setItem('dbOrders', '[]');}
if(localStorage.getItem('dbOrderReturns') == null){localStorage.setItem('dbOrderReturns', '[]');}
if(localStorage.getItem('dbTimesheets') == null){localStorage.setItem('dbTimesheets', '[]');}
if(localStorage.getItem('dbCoupons') == null){localStorage.setItem('dbCoupons', '[]');}
if(localStorage.getItem('dbTills') == null){localStorage.setItem('dbTills', '[]');}
dbProducts.load({ data: JSON.parse(localStorage.getItem('dbProducts')) });



// General Globals
var currentSale=null;
var currentReturn=null;
var pages=null;
var itemButtons=null;
var currentPage = null;
//var baseUrl = 'http://127.0.0.1:3000'
var baseUrl = 'http://192.168.1.9:3000'

// Register Globals
var globalCompanyToken = localStorage.getItem('company_token');
var globalCompanyName = localStorage.getItem('company_name');
var globalEmployeeId = localStorage.getItem('employee_id');
var globalEmployeeName = localStorage.getItem('employee_name');
var globalRegisterId = localStorage.getItem('register_id');
var globalRegisterName = localStorage.getItem('register_name');
var globalStoreAddress = localStorage.getItem('store_address');
var globalStoreId = localStorage.getItem('store_id');
var globalStoreName = localStorage.getItem('store_name');
var globalGateway = localStorage.getItem('store_gateway');
var globalTaxRate = parseFloat(localStorage.getItem('tax_rate'));

// Login Globals
var globalStores = JSON.parse(localStorage.getItem('all_stores'));
var globalRegisters = JSON.parse(localStorage.getItem('all_registers'));