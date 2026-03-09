
class InvoicesDetailModel {
  //TODO تفاصيل للفواتير
  int _id = 0;
  String _invoices_id = "1"; // 'رقم الفاتورة'
  String _item_no ='5100';   //'رقم الصنف'
  String _item_name ='gh';//'اسم الصنف'
  String _unit_name ='وحدة';//'الوحدة'
  String _unit_qty ='12';// 'الكمية'
  String _unit_price ='12';//'سعر الوحدة'
  String _net_price ='12';//'الإجمالي'


    // CREATE TABLE "invoices_detail" (
  // "ID_id"	INTEGER NOT NULL UNIQUE,
  // "ID_invoices_id"	TEXT DEFAULT 'رقم الفاتورة',
  // "ID_item_no"	TEXT DEFAULT 'رقم الصنف',
  // "ID_item_name"	TEXT DEFAULT 'اسم الصنف',
  // "ID_unit_name"	TEXT DEFAULT 'الوحدة',
  // "ID_unit_qty"	TEXT DEFAULT 'الكمية',
  // "ID_unit_price"	TEXT DEFAULT 'سعر الوحدة',
  // "ID_net_price"	TEXT DEFAULT 'الإجمالي',

  InvoicesDetailModel.name();
  InvoicesDetailModel(dynamic obj) {
     _id =obj["ID_id"] as int;
     _invoices_id = obj["ID_invoices_id"]; // 'رقم الفاتورة'
     _item_no =obj["ID_item_no"];   //'رقم الصنف'
     _item_name =obj["ID_item_name"];//'اسم الصنف'
     _unit_name =obj["ID_unit_name"];//'الوحدة'
     _unit_qty =obj["ID_unit_qty"];// 'الكمية'
     _unit_price =obj["ID_unit_price"];//'سعر الوحدة'
     _net_price =obj["ID_net_price"];//'الإجمالي'
  }

  InvoicesDetailModel.full({
    required int id,
    required String invoicesId,
    String itemNo = '',
    String itemName = '',
    String unitName = 'وحدة',
    String unitQty = '1',
    String unitPrice = '0',
    String netPrice = '0',
  }) {
    _id = id;
    _invoices_id = invoicesId;
    _item_no = itemNo;
    _item_name = itemName;
    _unit_name = unitName;
    _unit_qty = unitQty;
    _unit_price = unitPrice;
    _net_price = netPrice;
  }

  InvoicesDetailModel.fromMap(Map<String, dynamic> obj) {
    _id =obj["ID_id"] as int;
    _invoices_id = obj["ID_invoices_id"]; // 'رقم الفاتورة'
    _item_no =obj["ID_item_no"];   //'رقم الصنف'
    _item_name =obj["ID_item_name"];//'اسم الصنف'
    _unit_name =obj["ID_unit_name"];//'الوحدة'
    _unit_qty =obj["ID_unit_qty"];// 'الكمية'
    _unit_price =obj["ID_unit_price"];//'سعر الوحدة'
    _net_price =obj["ID_net_price"];//'الإجمالي'
  }



  Map<String, dynamic> toMap() => {
  "ID_id": _id,
  "ID_invoices_id": _invoices_id, // 'رقم الفاتورة'
  "ID_item_no":_item_no,   //'رقم الصنف'
  "ID_item_name":_item_name,//'اسم الصنف'
  "ID_unit_name": _unit_name ,//'الوحدة'
  "ID_unit_qty":_unit_qty ,// 'الكمية'
  "ID_unit_price":_unit_price,//'سعر الوحدة'
  "ID_net_price":_net_price ,//'الإجمالي'
  };

  int get id => _id;

  set id(int value) {
    _id = value;
  }
  String get invoices_id => _invoices_id;

  set invoices_id(String value) {
    _invoices_id = value;
  }

  String get item_no => _item_no;

  set item_no(String value) {
    _item_no = value;
  }

  String get item_name => _item_name;

  set item_name(String value) {
    _item_name = value;
  }

  String get unit_name => _unit_name;

  set unit_name(String value) {
    _unit_name = value;
  }

  String get unit_qty => _unit_qty;

  set unit_qty(String value) {
    _unit_qty = value;
  }

  String get unit_price => _unit_price;

  set unit_price(String value) {
    _unit_price = value;
  }

  String get net_price => _net_price;

  set net_price(String value) {
    _net_price = value;
  }
}

