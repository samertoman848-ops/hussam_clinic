import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/vouchers/dbvouchers.dart';
import 'package:hussam_clinc/model/accounting/VoucherModel.dart';
import 'package:hussam_clinc/theme/app_theme.dart';

class ReceiptVouchersReview extends StatefulWidget {
  final String type; // 'قبض' or 'صرف'
  const ReceiptVouchersReview({super.key, this.type = 'قبض'});

  @override
  State<ReceiptVouchersReview> createState() => _ReceiptVouchersReviewState();
}

class _ReceiptVouchersReviewState extends State<ReceiptVouchersReview> {
  List<VoucherModel> _items = [];
  final DbVouchers _db = DbVouchers();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await _db.dbHelper.openDb();
    final res = await db!.rawQuery(
        "SELECT * FROM vouchers WHERE voucher_class='${widget.type}';");
    setState(() {
      _items = res.map((e) => VoucherModel.fromMap(e)).toList();
    });
  }

  Future<void> _delete(int id) async {
    final db = await _db.dbHelper.openDb();
    await db!.rawDelete('DELETE FROM vouchers WHERE voucher_id=?', [id]);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: Text(
            widget.type == 'قبض'
                ? 'مراجعة إيصالات القبض'
                : 'مراجعة إيصالات الصرف',
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
        body: _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد إيصالات',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final it = _items[i];
                  return _buildVoucherCard(it);
                },
              ),
      ),
    );
  }

  Widget _buildVoucherCard(VoucherModel voucher) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الإيصال',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.className,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'التاريخ والوقت',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${voucher.date} ${voucher.time}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              // Details
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildDetailItem(
                      icon: Icons.pin_outlined,
                      label: 'رقم الحساب',
                      value: voucher.account,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildDetailItem(
                      icon: Icons.person_outline,
                      label: 'الطرف',
                      value: voucher.dealer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.monetization_on_outlined,
                label: 'المبلغ',
                value: '${voucher.payment} ${voucher.className}',
                valueColor: AppTheme.accentColor,
              ),
              if (voucher.discription.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailItem(
                  icon: Icons.note_outlined,
                  label: 'ملاحظات',
                  value: voucher.discription,
                ),
              ],
              const SizedBox(height: 12),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('تأكيد الحذف'),
                          content:
                              const Text('هل أنت متأكد من حذف هذا الإيصال؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await _delete(voucher.id);
                      }
                    },
                    label: const Text('حذف'),
                    icon: const Icon(Icons.delete_outline_rounded),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
