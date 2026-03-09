class AccoutingTreeModel {
  //TODO الإجمالي للفواتير
  int _id = 1;
  String _name ='5100';   //'رقم الزبون'
  String _branch_no ='gh';//'اسم الزبون أو المورد'
  String _father_no ='1344';//'قيمة الفاتورة'
  String _branch_originalId ='شيكل';// 'رقم القيد'

  AccoutingTreeModel.empty();

  AccoutingTreeModel.Valueed(
      this._id,
      this._name,
      this._branch_no,
      this._father_no,
      this._branch_originalId); // CREATE TABLE "accounting_tree" (
  // "AT_id"	INTEGER NOT NULL UNIQUE,
  // "AT_name"	TEXT,
  // "AT_branch_no"	TEXT,
  // "AT_father_no"	TEXT,
  // "AT_branch_originalId"	TEXT,
  // PRIMARY KEY("AT_id" AUTOINCREMENT)
  // );

  AccoutingTreeModel(dynamic obj) {
    _id = int.tryParse(obj["AT_id"]?.toString() ?? '') ?? 0;
    _name = obj["AT_name"]?.toString() ?? '';//'رقم الزبون'
    _branch_no = obj["AT_branch_no"]?.toString() ?? '';//'اسم الزبون أو المورد'
    _father_no = obj["AT_father_no"]?.toString() ?? '';//'قيمة الفاتورة'
    _branch_originalId = obj["AT_branch_originalId"]?.toString() ?? '';// 'رقم القيد'
  }

  AccoutingTreeModel.fromMap(Map<String, dynamic> obj) {
    _id = int.tryParse(obj["AT_id"]?.toString() ?? '') ?? 0;
    _name = obj["AT_name"]?.toString() ?? '';//'رقم الزبون'
    _branch_no = obj["AT_branch_no"]?.toString() ?? '';//'اسم الزبون أو المورد'
    _father_no = obj["AT_father_no"]?.toString() ?? '';//'قيمة الفاتورة'
    _branch_originalId = obj["AT_branch_originalId"]?.toString() ?? '';// 'رقم القيد'

  }
  Map<String, dynamic> toMap() => {
  "AT_id":_id ,
  "AT_name":_name,//'رقم الزبون'
  "AT_branch_no": _branch_no,//'اسم الزبون أو المورد'
  "AT_father_no":_father_no,//'قيمة الفاتورة'
  "AT_branch_originalId":_branch_originalId,// 'رقم القيد'
  };

  String get branch_originalId => _branch_originalId;

  set branch_originalId(String value) {
    _branch_originalId = value;
  }

  String get father_no => _father_no;

  set father_no(String value) {
    _father_no = value;
  }

  String get branch_no => _branch_no;

  set branch_no(String value) {
    _branch_no = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}

