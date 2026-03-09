/// this is تفاصيل  البضاعة
class IndexModel {
  int _no = 1;
  String _name ='1';   //رقم القيد'
  String _description ='5100';   //'الوصف' 
  String _type ='gh';//'بصاعة -عمل'
  String _unit_name ='وحدة';// 'وحدة'
  String _balance ='34';// 'الرصيد'
  String _min_qty ='23';// 'أقل كمية'
  String _max_qty ='120';// 'أعلي كمية'
  String _selling_price ='40';// 'سعر البيع'
  String _selling_currency='شيكل';// 'عملة سعر البيع',
  String _buying_price='';//'سعر الشراء'
  String _buying_currency='شيكل';// 'عملة سعر الشراء'
  String _last_tran_date='';// 'تاريخ أخر حركة'
  String _ini_balance='';

  IndexModel.name(
    ); // 'رصيد أول المدة'

/*  "index_no"	INTEGER NOT NULL UNIQUE,
  "index_name"	TEXT DEFAULT 'الكشف',
  "index_description"	TEXT DEFAULT 'الوصف',
  "index_type"	TEXT DEFAULT 'بصاعة -عمل',
  "index_unit_name"	TEXT DEFAULT 'وحدة',
  "index_balance"	TEXT DEFAULT 'الرصيد',
  "index_min_qty"	TEXT DEFAULT 'أقل كمية',
  "index_max_qty"	TEXT DEFAULT 'أعلي كمية',
  "index_selling_price"	TEXT DEFAULT 'سعر البيع',
  "index_selling_currency"	TEXT DEFAULT 'عملة سعر البيع',
  "index_buying_price"	TEXT DEFAULT 'سعر الشراء',
  "index_buying_currency"	TEXT DEFAULT 'عملة سعر الشراء',
  "index_last_tran_date"	TEXT DEFAULT 'تاريخ أخر حركة',
  "index_ini_balance"	TEXT DEFAULT 'رصيد أول المدة',*/

  IndexModel(dynamic obj) {
    _no =obj["index_no"] as int;
    _name =obj["index_name"] ;
    _description =obj["index_description"] ;
    _type =  obj["index_type"];
    _unit_name =obj["index_unit_name"];
    _balance =obj["index_balance"];
    _min_qty =obj["index_min_qty"];
    _max_qty =obj["index_max_qty"];
    _selling_price =obj["index_selling_price"];
    _selling_currency =obj["index_selling_currency"];
    _buying_price=obj["index_buying_price"];
    _buying_currency=obj["index_buying_currency"];
    _last_tran_date=obj["index_last_tran_date"];
    _ini_balance=obj["index_ini_balance"];
  }

  IndexModel.fromMap(Map<String, dynamic> obj) {
    _no =obj["index_no"] as int;
    _name =obj["index_name"] ;
    _description =obj["index_description"] ;
    _type =  obj["index_type"];
    _unit_name =obj["index_unit_name"];
    _balance =obj["index_balance"];
    _min_qty =obj["index_min_qty"];
    _max_qty =obj["index_max_qty"];
    _selling_price =obj["index_selling_price"];
    _selling_currency =obj["index_selling_currency"];
    _buying_price=obj["index_buying_price"];
    _buying_currency=obj["index_buying_currency"];
    _last_tran_date=obj["index_last_tran_date"];
    _ini_balance=obj["index_ini_balance"];
  }

  Map<String, dynamic> toMap() => {
    "index_no":_no ,
    "index_name":_name,
    "index_description":_description,
    "index_type":_type ,
    "index_unit_name":_unit_name,
    "index_min_qty":_min_qty,
    "index_balance": _balance ,
    "index_max_qty":_max_qty ,
    "index_selling_price":_selling_price,
    "index_selling_currency": _selling_currency ,
    "index_buying_price":_buying_price,
    "index _buying_currency": _buying_currency,
    "index_last_tran_date":_last_tran_date,
    "index_ini_balance": _ini_balance,
  };

  String get ini_balance => _ini_balance;

  set ini_balance(String value) {
    _ini_balance = value;
  }

  String get last_tran_date => _last_tran_date;

  set last_tran_date(String value) {
    _last_tran_date = value;
  }

  String get buying_currency => _buying_currency;

  set buying_currency(String value) {
    _buying_currency = value;
  }

  String get buying_price => _buying_price;

  set buying_price(String value) {
    _buying_price = value;
  }

  String get selling_currency => _selling_currency;

  set selling_currency(String value) {
    _selling_currency = value;
  }

  String get selling_price => _selling_price;

  set selling_price(String value) {
    _selling_price = value;
  }

  String get max_qty => _max_qty;

  set max_qty(String value) {
    _max_qty = value;
  }

  String get min_qty => _min_qty;

  set min_qty(String value) {
    _min_qty = value;
  }

  String get balance => _balance;

  set balance(String value) {
    _balance = value;
  }

  String get unit_name => _unit_name;

  set unit_name(String value) {
    _unit_name = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  int get no => _no;

  set no(int value) {
    _no = value;
  }
}

