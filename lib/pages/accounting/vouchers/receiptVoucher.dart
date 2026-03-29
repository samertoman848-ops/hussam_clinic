import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournaldetails.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournals.dart';
import 'package:hussam_clinc/db/accounting/vouchers/dbvouchers.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/model/accounting/VoucherModel.dart';
import 'package:intl/intl.dart' as tt;

class ReceiptVoucherPage extends StatefulWidget {
  final String type; // 'قبض' or 'صرف'
  final VoucherModel? voucher;
  final bool isEdit;
  const ReceiptVoucherPage({super.key, this.type = 'قبض', this.voucher, this.isEdit = false});

  @override
  State<ReceiptVoucherPage> createState() => _ReceiptVoucherPageState();
}

class _ReceiptVoucherPageState extends State<ReceiptVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNo = TextEditingController();
  final _accountName = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  String _currency = 'شيكل';
  int? _voucherNo;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _currencyList = ['شيكل', 'دولار', 'دينار'];

  @override
  void dispose() {
    _accountNo.dispose();
    _accountName.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.voucher != null) {
      _voucherNo = widget.voucher!.id;
      _accountNo.text = widget.voucher!.account;
      _accountName.text = widget.voucher!.dealer;
      _amount.text = widget.voucher!.payment;
      _notes.text = widget.voucher!.discription;
      _currency = widget.voucher!.currency;
      try {
        _selectedDate = tt.DateFormat("dd/MM/yyyy").parse(widget.voucher!.date.split(' ')[0]);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
    } else {
      _loadNextVoucherNo();
    }
    _amount.addListener(() {
      setState(() {}); // Rebuild to update amount display
    });
  }

  Future<void> _loadNextVoucherNo() async {
    try {
      final db = await DbVouchers().dbHelper.openDb();
      final res = await db!.rawQuery(
          "SELECT MAX(voucher_id) as m FROM vouchers WHERE voucher_class='${widget.type}';");
      final m = res.isNotEmpty && res.first['m'] != null
          ? int.tryParse(res.first['m'].toString()) ?? 0
          : 0;
      setState(() {
        _voucherNo = m + 1;
      });
    } catch (_) {
      setState(() {
        _voucherNo = null;
      });
    }
  }

  Future<DateTime?> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
    return pickedDate;
  }

  Future<TimeOfDay?> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() => _selectedTime = pickedTime);
    }
    return pickedTime;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dbV = DbVouchers();
    final dbJ = DbJournals();
    final dbJD = DbJournalDetails();
    
    final dateTimeStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final timeStr = '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    
    try {
      if (widget.isEdit && widget.voucher != null) {
        final journalId = widget.voucher!.jornal;
        
        // 1. Update Journal Header
        await dbJ.updatejournals(
          dateTimeStr,
          timeStr,
          _amount.text,
          _currency,
          "1", // Rate
          "${widget.type == 'قبض' ? 'إيصال قبض' : 'إيصال صرف'} رقم ${widget.voucher!.id} / ${_accountName.text}",
          journalId,
        );

        // 2. Clear and Re-add Journal Details (Double Entry)
        await dbJD.deleteJournalDetailsByJournalId(journalId);
        
        if (widget.type == 'قبض') {
          // Debit: Box
          await dbJD.addjournalDetails(journalId, "120101", "صندوق العيادة", _amount.text, "0", _notes.text, _currency, "1", _amount.text);
          // Credit: Patient
          await dbJD.addjournalDetails(journalId, _accountNo.text, _accountName.text, "0", _amount.text, _notes.text, _currency, "1", _amount.text);
        } else {
          // Debit: Account
          await dbJD.addjournalDetails(journalId, _accountNo.text, _accountName.text, _amount.text, "0", _notes.text, _currency, "1", _amount.text);
          // Credit: Box
          await dbJD.addjournalDetails(journalId, "120101", "صندوق العيادة", "0", _amount.text, _notes.text, _currency, "1", _amount.text);
        }

        // 3. Update Voucher
        final dbConn = await dbV.dbHelper.openDb();
        await dbConn!.update(
          'vouchers',
          {
            'voucher_date': '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            'voucher_time': timeStr,
            'voucher_account': _accountNo.text,
            'voucher_dealer': _accountName.text,
            'voucher_payment': _amount.text,
            'voucher_currency': _currency,
            'voucher_discription': _notes.text,
          },
          where: 'voucher_id = ?',
          whereArgs: [widget.voucher!.id],
        );
      } else {
        // NEW VOUCHER
        // 1. Create Journal Entry First to get ID (using a temporary unique strategy or getting max)
        final dbConn = await dbV.dbHelper.openDb();
        
        // Add Journal Header
        await dbJ.addjournals(
          dateTimeStr,
          timeStr,
          _amount.text,
          _currency,
          "1",
          "${widget.type == 'قبض' ? 'إيصال قبض' : 'إيصال صرف'} / ${_accountName.text}",
        );
        
        final lastJ = await dbConn!.rawQuery("SELECT MAX(journal_id) as id FROM journals");
        final journalId = lastJ.first['id'].toString();

        // 2. Add Journal Details (Double Entry)
        if (widget.type == 'قبض') {
          await dbJD.addjournalDetails(journalId, "120101", "صندوق العيادة", _amount.text, "0", _notes.text, _currency, "1", _amount.text);
          await dbJD.addjournalDetails(journalId, _accountNo.text, _accountName.text, "0", _amount.text, _notes.text, _currency, "1", _amount.text);
        } else {
          await dbJD.addjournalDetails(journalId, _accountNo.text, _accountName.text, _amount.text, "0", _notes.text, _currency, "1", _amount.text);
          await dbJD.addjournalDetails(journalId, "120101", "صندوق العيادة", "0", _amount.text, _notes.text, _currency, "1", _amount.text);
        }

        // 3. Add Voucher Header
        await dbV.addVouchers(
          _accountNo.text,
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          timeStr,
          _accountName.text,
          _amount.text,
          _currency,
          journalId,
          _notes.text,
          widget.type,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdit 
                ? 'تم تحديث السند والقيد بنجاح' 
                : (widget.type == 'قبض' ? 'تم حفظ إيصال القبض والقيد المحاسبي' : 'تم حفظ إيصال الصرف والقيد المحاسبي')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحفظ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D9D99),
        title: Text(
            widget.isEdit ? (widget.type == 'قبض' ? 'تعديل إيصال قبض' : 'تعديل إيصال صرف')
            : (widget.type == 'قبض' ? 'إيصال قبض' : 'إيصال صرف'),
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
              tooltip: 'مسح الحقول',
              onPressed: () {
                _accountNo.clear();
                _accountName.clear();
                _amount.clear();
                _notes.clear();
              },
            ),
    IconButton(
      icon: const Icon(Icons.save_rounded, color: Colors.white),
      tooltip: 'حفظ الإيصال',
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(widget.isEdit ? 'تأكيد التعديل' : 'تأكيد الحفظ'),
            content: Text(widget.isEdit ? 'هل تريد حفظ التعديلات على هذا الإيصال؟' : 'هل تريد حفظ هذا الإيصال الجديد؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _save();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D9D99)),
                child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 16),
                      _buildDetailsCard(),
                      const SizedBox(height: 16),
                      _buildNotesCard(),
                    ],
                  ),
                ),
              ),
              _buildSummaryCard(),
            ],
          ),
        ),
      );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.confirmation_number_outlined,
                label: 'رقم السند',
                value: _voucherNo?.toString() ?? '-',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInteractiveItem(
                icon: Icons.calendar_today_outlined,
                label: 'التاريخ',
                value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                onTap: () => _pickDate(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInteractiveItem(
                icon: Icons.access_time_outlined,
                label: 'الوقت',
                value: '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                onTap: () => _pickTime(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _accountNo,
                    decoration: InputDecoration(
                      labelText: 'رقم الحساب',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _accountName,
                    decoration: InputDecoration(
                      labelText: 'اسم الحساب',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'المبلغ',
                      suffixText: _currency,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currency,
                        isExpanded: true,
                        items: _currencyList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _currency = val!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _notes,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'ملاحظات',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('نوع السند: ${widget.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('المبلغ الإجمالي: ${_amount.text} $_currency', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInteractiveItem({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D9D99))),
        ],
      ),
    );
  }
}
