import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/vouchers/dbvouchers.dart';
import 'package:hussam_clinc/theme/app_theme.dart';

class ReceiptVoucherPage extends StatefulWidget {
  final String type; // 'قبض' or 'صرف'
  const ReceiptVoucherPage({super.key, this.type = 'قبض'});

  @override
  State<ReceiptVoucherPage> createState() => _ReceiptVoucherPageState();
}

class _ReceiptVoucherPageState extends State<ReceiptVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNo = TextEditingController();
  final _accountName = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  String _currency = 'SAR';
  int? _voucherNo;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _currencyList = ['SAR', 'USD', 'AED', 'EGP', 'KWD'];

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
    _loadNextVoucherNo();
    _amount.addListener(() {
      setState(() {}); // Rebuild to update amount display
    });
  }

  Future<void> _loadNextVoucherNo() async {
    try {
      final db = await DbVouchers().dbHelper.openDb();
      final res = await db!.rawQuery(
          "SELECT MAX(voucher_no) as m FROM vouchers WHERE voucher_class='${widget.type}';");
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

    final db = DbVouchers();
    final now = DateTime.now();

    // Combine date and time
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    await db.addVouchers(
      _accountNo.text,
      _selectedDate.toString().split(' ').first,
      dateTime.toIso8601String(),
      _accountName.text,
      _amount.text,
      _currency,
      '', // jornal
      _notes.text,
      widget.type,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.type == 'قبض'
              ? 'تم حفظ إيصال القبض'
              : 'تم حفظ إيصال الصرف'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
            widget.type == 'قبض' ? 'إيصال قبض' : 'إيصال صرف',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          actions: [
            _buildAppBarAction(
              icon: Icons.delete_outline_rounded,
              tooltip: 'مسح الحقول',
              onPressed: () => _showConfirmDialog(
                context,
                title: 'مسح البيانات',
                message: 'هل تريد مسح جميع البيانات المدخلة؟',
                onConfirm: () {
                  _accountNo.clear();
                  _accountName.clear();
                  _amount.clear();
                  _notes.clear();
                  Navigator.pop(context);
                },
              ),
            ),
            _buildAppBarAction(
              icon: Icons.save_rounded,
              tooltip: 'حفظ الإيصال',
              onPressed: () => _showConfirmDialog(
                context,
                title: 'حفظ الإيصال',
                message:
                    'هل أنت متأكد من إضافة هذا ${widget.type == 'قبض' ? 'الإيصال' : 'الإيصال'} للنظام؟',
                onConfirm: _save,
              ),
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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                context,
                icon: Icons.calendar_today_outlined,
                label: 'التاريخ',
                value:
                    '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                onTap: () => _pickDate(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInteractiveItem(
                context,
                icon: Icons.access_time_outlined,
                label: 'الوقت',
                value:
                    '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                onTap: () => _pickTime(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCurrencyDropdown(),
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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pin_outlined,
                              size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text('رقم الحساب', style: _textStyleLabel),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _accountNo,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.credit_card,
                              color: AppTheme.primaryColor),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'أدخل رقم الحساب',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 16, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text('اسم الطرف / المحاسب', style: _textStyleLabel),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _accountName,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person,
                              color: AppTheme.primaryColor),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'أدخل اسم الطرف',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text('المبلغ', style: _textStyleLabel),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: _currency,
                    prefixIcon: const Icon(Icons.monetization_on,
                        color: AppTheme.primaryColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    hintText: 'أدخل المبلغ',
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_outlined, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text('ملاحظات (اختياري)', style: _textStyleLabel),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.note, color: AppTheme.primaryColor),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'أضف أي ملاحظات إضافية',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final amount = double.tryParse(_amount.text) ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAmountDisplay(
              'نوع الإيصال',
              widget.type == 'قبض' ? 'إيصال قبض' : 'إيصال صرف',
              Colors.blue,
            ),
            _buildAmountDisplay(
              'المبلغ',
              '${amount.toStringAsFixed(2)} $_currency',
              AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 4),
            Text(label, style: _textStyleLabel),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: _textStyle),
      ],
    );
  }

  Widget _buildInteractiveItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 4),
                Text(label, style: _textStyleLabel),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: _textStyle.copyWith(color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.currency_exchange, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 4),
            Text('العملة', style: _textStyleLabel),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currency,
              isExpanded: true,
              items: _currencyList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _currency = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountDisplay(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  TextStyle get _textStyleLabel => const TextStyle(
        fontSize: 12,
        color: Colors.blueGrey,
        fontWeight: FontWeight.w500,
      );

  TextStyle get _textStyle => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );
}
