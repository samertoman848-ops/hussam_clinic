import 'package:flutter/material.dart';
import 'package:hussam_clinc/View_model/ViewModelJournals.dart';
import 'package:hussam_clinc/datasource/journalsReview_datasource.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournals.dart';
import 'package:hussam_clinc/pages/accounting/journals/journalsPage.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../global_var/globals.dart';
import '../../../main.dart';

class JournalsReview extends StatefulWidget {
  const JournalsReview({super.key});

  @override
  State<StatefulWidget> createState() => JournalsReviewState();
}

class JournalsReviewState extends State<JournalsReview> {
  late JournalsReviewDataSource journalsReviewDataSource;
  final DataGridController _dataGridController = DataGridController();
  final DbJournals _dbJournals = DbJournals();

  @override
  void initState() {
    super.initState();
    _buildDataSource();
  }

  void _buildDataSource() {
    journalsReviewDataSource = JournalsReviewDataSource(
      journalsModel: allJournals,
      onEdit: _handleEdit,
      onDelete: _handleDelete,
    );
  }

  Future<void> _reloadJournals() async {
    await Journals();
    if (mounted) {
      setState(() {
        _buildDataSource();
      });
    }
  }

  /// التعديل: تحميل بيانات القيد ثم فتح صفحة التعديل
  Future<void> _handleEdit(BuildContext ctx, String id) async {
    await VMJournals.EditeAlreadyJournals(id);
    VMJournals.MaxInvoices = id;
    VMJournals.Maxjournals = id;
    AllEmplyess();
    if (ctx.mounted) {
      await Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => const JournalsPage()),
      );
      await _reloadJournals();
    }
  }

  /// الحذف: حذف القيد وكل ما يرتبط به بعد التأكيد
  Future<void> _handleDelete(BuildContext ctx, String id) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف القيد رقم $id؟'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                'سيتم حذف القيد وكل ما يرتبط به:\n• تفاصيل القيد\n• الفواتير المرتبطة\n• سندات القبض/الصرف',
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogCtx, true),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbJournals.deleteJournal(id);
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('تم حذف القيد رقم $id وجميع السجلات المرتبطة به'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _reloadJournals();
      } catch (e) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('خطأ في الحذف: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D9D99),
          title: const Text(
            'القيود المحاسبية',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Tooltip(
                message: 'قيد جديد',
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () async {
                    VMJournals = ViewModelJournals.impty();
                    AllEmplyess();
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const JournalsPage()),
                    );
                    await _reloadJournals();
                  },
                ),
              ),
            ),
          ],
        ),
        body: SfDataGridTheme(
          data: SfDataGridThemeData(headerColor: const Color(0xff009889)),
          child: SfDataGrid(
            selectionMode: SelectionMode.single,
            frozenColumnsCount: 1,
            allowColumnsResizing: true,
            allowFiltering: true,
            navigationMode: GridNavigationMode.cell,
            columnWidthMode: ColumnWidthMode.auto,
            allowSorting: true,
            controller: _dataGridController,
            source: journalsReviewDataSource,
            columns: _buildColumns(),
          ),
        ),
      ),
    );
  }

  List<GridColumn> _buildColumns() {
    return [
      GridColumn(
        columnName: '_id',
        allowFiltering: true,
        allowSorting: true,
        columnWidthMode: ColumnWidthMode.fitByColumnName,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: const Text('#'),
        ),
      ),
      GridColumn(
        columnName: '_date',
        allowFiltering: true,
        allowSorting: true,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('التاريخ'),
        ),
      ),
      GridColumn(
        columnName: '_time',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('الوقت', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: '_discription',
        allowFiltering: true,
        minimumWidth: 200,
        width: 300,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('البيان'),
        ),
      ),
      GridColumn(
        columnName: '_amount',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('قيمة القيد'),
        ),
      ),
      GridColumn(
        columnName: '_currency',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('عملة القيد'),
        ),
      ),
      GridColumn(
        columnName: '_rate',
        minimumWidth: 50,
        width: 120,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('سعر العملة'),
        ),
      ),
      GridColumn(
        columnName: '_ry',
        minimumWidth: 50,
        width: 120,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('مبلغ الحساب'),
        ),
      ),
      GridColumn(
        columnName: '_edit',
        allowFiltering: false,
        allowSorting: false,
        columnWidthMode: ColumnWidthMode.fitByColumnName,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('تعديل'),
        ),
      ),
      GridColumn(
        columnName: '_delete',
        allowFiltering: false,
        allowSorting: false,
        columnWidthMode: ColumnWidthMode.fitByColumnName,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('حذف'),
        ),
      ),
    ];
  }
}
