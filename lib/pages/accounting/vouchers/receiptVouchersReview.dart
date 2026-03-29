import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/vouchers/dbvouchers.dart';
import 'package:hussam_clinc/model/accounting/VoucherModel.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../datasource/vouchersReview_datasource.dart';
import 'package:hussam_clinc/pages/accounting/vouchers/receiptVoucher.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/main.dart';

class ReceiptVouchersReview extends StatefulWidget {
  final String type; // 'قبض' or 'صرف'
  const ReceiptVouchersReview({super.key, this.type = 'قبض'});

  @override
  State<ReceiptVouchersReview> createState() => _ReceiptVouchersReviewState();
}

class _ReceiptVouchersReviewState extends State<ReceiptVouchersReview> {
  List<VoucherModel> _items = [];
  final DbVouchers _db = DbVouchers();
  late VouchersReviewDataSource _vouchersDataSource;

  @override
  void initState() {
    super.initState();
    _vouchersDataSource = VouchersReviewDataSource(
        vouchersData: [], onDelete: (ctx, id) => _confirmDelete(ctx, id));
    _load();
  }

  Future<void> _load() async {
    final db = await _db.dbHelper.openDb();
    final res = await db!.rawQuery(
        "SELECT * FROM vouchers WHERE voucher_class='${widget.type}';");
    setState(() {
      _items = res.map((e) => VoucherModel.fromMap(e)).toList();
      _vouchersDataSource = VouchersReviewDataSource(
          vouchersData: _items, onDelete: (ctx, id) => _confirmDelete(ctx, id));
    });
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الإيصال؟'),
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
      final db = await _db.dbHelper.openDb();
      await db!.rawDelete('DELETE FROM vouchers WHERE voucher_id=?', [id]);
      await _load();
    }
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
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              tooltip: 'إضافة إيصال',
              onPressed: () async {
                VMGlobal.MaxNoS();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptVoucherPage(
                      type: widget.type,
                    ),
                  ),
                );
                await _load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'تحديث البيانات',
              onPressed: () async {
                await _load();
              },
            ),
          ],
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
                    const Text('لا توجد إيصالات'),
                  ],
                ),
              )
            : SfDataGridTheme(
                data: SfDataGridThemeData(headerColor: const Color(0xff009889)),
                child: SfDataGrid(
                  selectionMode: SelectionMode.single,
                  allowColumnsResizing: true,
                  allowFiltering: true,
                  navigationMode: GridNavigationMode.cell,
                  columnWidthMode: ColumnWidthMode.auto,
                  allowSorting: true,
                  source: _vouchersDataSource,
                  columns: _buildColumns(),
                ),
              ),
      ),
    );
  }

  List<GridColumn> _buildColumns() {
    return [
      GridColumn(
        columnName: 'id',
        label: Container(alignment: Alignment.center, child: const Text('#')),
      ),
      GridColumn(
        columnName: 'date',
        label: Container(
            alignment: Alignment.center, child: const Text('التاريخ')),
      ),
      GridColumn(
        columnName: 'time',
        label:
            Container(alignment: Alignment.center, child: const Text('الوقت')),
      ),
      GridColumn(
        columnName: 'account',
        label: Container(
            alignment: Alignment.center, child: const Text('رقم الحساب')),
      ),
      GridColumn(
        columnName: 'dealer',
        label:
            Container(alignment: Alignment.center, child: const Text('الاسم')),
      ),
      GridColumn(
        columnName: 'patient_link',
        label: Container(
            alignment: Alignment.center, child: const Text('ملف المريض')),
      ),
      GridColumn(
        columnName: 'journal',
        label: Container(
            alignment: Alignment.center, child: const Text('رقم القيد')),
      ),
      GridColumn(
        columnName: 'payment',
        label:
            Container(alignment: Alignment.center, child: const Text('المبلغ')),
      ),
      GridColumn(
        columnName: 'currency',
        label:
            Container(alignment: Alignment.center, child: const Text('العملة')),
      ),
      GridColumn(
        columnName: 'class',
        label: Container(
            alignment: Alignment.center, child: const Text('نوع السند')),
      ),
      GridColumn(
        columnName: 'description',
        label: Container(
            alignment: Alignment.center, child: const Text('الملاحظات')),
      ),
      GridColumn(
        columnName: '_delete',
        label: Container(alignment: Alignment.center, child: const Text('حذف')),
      ),
    ];
  }
}
