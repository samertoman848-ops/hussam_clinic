/// this is تفاصيل القيود المحاسبية
class JournalsDetailModel {
  int _id = 1;
  String _journal_id ='1';   //رقم القيد'
  String _account_id ='5100';   //رقم الحساب'
  String _account_name ='gh';//'اسم الحساب'
  String _debit ='1344';// 'مدين'
  String _credit ='شيكل';// 'دائن'
  String _description ='الوصف';// 'الوصف'
  String _currency ='شيكل';// 'العملة'
  String _rate ='12';// 'سعر العملة',
  String _acc_amount ='2323';// 'مبلغ الحساب',

/* CREATE TABLE "journals_detail" (
	"JD_id"	INTEGER NOT NULL UNIQUE,
	"JD_account_id"	TEXT DEFAULT 'رقم الحساب',
	"JD_account_name"	TEXT DEFAULT 'اسم الحساب',
	"JD_debit"	TEXT DEFAULT 'مدين',
	"JD_credit"	TEXT DEFAULT 'دائن',
	"JD_description"	TEXT DEFAULT 'الوصف',
	"JD_currency"	TEXT DEFAULT 'العملة',
	"JD_rate"	TEXT DEFAULT 'سعر العملة',
	"JD_acc_amount"	TEXT DEFAULT 'مبلغ الحساب',
	PRIMARY KEY("JD_id" AUTOINCREMENT)*/

  JournalsDetailModel(dynamic obj) {
    _id =obj["JD_id"] as int;
    _journal_id =obj["JD_journal_id"] ;
    _account_id =obj["JD_account_id"] ;
    _account_name =  obj["JD_account_name"];
    _debit =obj["JD_debit"];
    _credit =obj["JD_credit"];
    _description =obj["JD_description"];
    _currency =obj["JD_currency"];
    _rate =obj["JD_rate"];
    _acc_amount =obj["JD_acc_amount"];
  }

  JournalsDetailModel.fromMap(Map<String, dynamic> obj) {
    _id =obj["JD_id"] as int;
    _journal_id =obj["JD_journal_id"] ;
    _account_id =obj["JD_account_id"] ;
    _account_name =  obj["JD_account_name"];
    _debit =obj["JD_debit"];
    _credit =obj["JD_credit"];
    _description =obj["JD_description"];
    _currency =obj["JD_currency"];
    _rate =obj["JD_rate"];
    _acc_amount =obj["JD_acc_amount"];
  }

  Map<String, dynamic> toMap() => {
    "JD_id":_id ,
    "JD_journal_id":_journal_id,
    "JD_account_id":_account_id,
    "JD_account_name":_account_name ,
    "JD_debit":_debit,
    "JD_currency":_currency,
    "JD_credit": _credit ,
    "JD_description":_description,
    "JD_rate":_rate ,
    "JD_acc_amount":_acc_amount,
  };

  String get acc_amount => _acc_amount;

  set acc_amount(String value) {
    _acc_amount = value;
  }

  String get rate => _rate;

  set rate(String value) {
    _rate = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get credit => _credit;

  set credit(String value) {
    _credit = value;
  }

  String get debit => _debit;

  set debit(String value) {
    _debit = value;
  }

  String get account_name => _account_name;

  set account_name(String value) {
    _account_name = value;
  }

  String get account_id => _account_id;

  set account_id(String value) {
    _account_id = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}

