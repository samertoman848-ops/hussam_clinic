import '../db/accounting/journal/dbjournaldetails.dart';

class ViewModelGlobal  {

  String Maxjournals='1';
  String MaxInvoices='1';
  String MaxVouchers='1';

  Future<void> MaxNoS() async {
    DbJournalDetails dbJournalDetails = DbJournalDetails();
    dbJournalDetails.MaxNoS();
  }
}

