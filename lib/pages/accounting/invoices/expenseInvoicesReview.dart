import 'package:flutter/material.dart';
import 'package:hussam_clinc/datasource/expenseReview_datasource.dart';
import 'package:hussam_clinc/View_model/ViewModelExpenseInvoices.dart';
import 'package:hussam_clinc/pages/accounting/invoices/expenseInvoices.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../global_var/globals.dart';
import '../../../main.dart';
import '../../../db/accounting/invoices/dbinvoices.dart';

const Color primaryColor = Color(0xffd0d4d7); //corner
const Color accentColor = Color(0xff3f86bd); //background
const TextStyle textStyle = TextStyle(color: Color(0xff7bb05d), fontSize: 14);
const TextStyle textStyleSubItems = TextStyle(color: Colors.grey);

class ExpenseInvoicesReview extends StatefulWidget {
  const ExpenseInvoicesReview({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExpenseInvoicesReviewState();
  }
}

class ExpenseInvoicesReviewState extends State<ExpenseInvoicesReview> {
  ExpenseReviewDataSource expenseReviewData = ExpenseReviewDataSource(expenseinvoicesData: []);
  final DataGridController _dataGridController = DataGridController();
  String? _lastTappedId; // لتتبع الضغطة الأولى والثانية

  @override
  void initState() {
    super.initState();
    void handleDelete(BuildContext ctx, String id) async {
      final confirmed = await showDialog<bool>(
        context: ctx,
        builder: (dctx) => AlertDialog(
          title:
              const Text('حذف الفاتورة', style: TextStyle(color: Colors.red)),
          content: const Text(
              'هل أنت متأكد من حذف هذه الفاتورة؟ سيتم حذفها نهائياً.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dctx, false),
                child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dctx, true),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        DbInvoices db = DbInvoices();
        await db.deleteInvoice(id);
        setState(() {
          expenseInvoices.removeWhere((inv) => inv.id.toString() == id);
          expenseReviewData = ExpenseReviewDataSource(
              expenseinvoicesData: expenseInvoices, onDelete: handleDelete);
        });
      }
    }

    ExpenseInvioces().then((_) {
      if (mounted) {
        setState(() {
          expenseReviewData = ExpenseReviewDataSource(
              expenseinvoicesData: expenseInvoices, onDelete: handleDelete);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D9D99),
          title: const Text(
            'فواتير المشتريات',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          actions: [
            // زر فاتورة جديدة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Tooltip(
                message: 'إنشاء فاتورة جديدة',
                child: IconButton(
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () async {
                    // تحضير بيانات الفاتورة الجديدة
                    AllEmplyess();
                    await AllSuppliersTreeList();
                    VMGlobal.MaxNoS();

                    // إنشاء فاتورة جديدة فارغة
                    VMExpenseInvoice = ViewModelExpenseInvoices.impty();
                    VMExpenseInvoice.EditeMode = false;
                    VMExpenseInvoice.checkValues();
                    VMExpenseInvoice.checkValues2();

                    if (mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ExpenseInvoices()),
                      );
                      // تحديث البيانات بعد العودة
                      ExpenseInvioces().then((_) {
                        if (mounted) {
                          setState(() {
                            // إعادة تهيئة الداتا سورس لتحديث القائمة
                            expenseReviewData = ExpenseReviewDataSource(
                                expenseinvoicesData: expenseInvoices);
                          });
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        body: SfDataGridTheme(
          data: SfDataGridThemeData(headerColor: const Color(0xff009889)),
          child: datatable(),
        ),
      ),
    );
  }

  SfDataGrid datatable() {
    return SfDataGrid(
      selectionMode: SelectionMode.single,
      frozenColumnsCount: 1,
      allowColumnsResizing: true,
      allowFiltering: true,
      navigationMode: GridNavigationMode.cell,
      columnWidthMode: ColumnWidthMode.auto,
      rowsPerPage: 30,
      editingGestureType: EditingGestureType.tap,
      controller: _dataGridController,
      onCellTap: (DataGridCellTapDetails details) async {
        final rowIdx = details.rowColumnIndex.rowIndex;
        if (rowIdx < 1) return;
        final row = expenseReviewData.effectiveRows[rowIdx - 1];
        String s = row.getCells()[0].value.toString();
        String sm = row.getCells()[5].value.toString();

        // الضغطة الأولى: تحميل البيانات وانتظار اكتمالها
        if (_lastTappedId != s) {
          setState(() {
            _lastTappedId = s;
          });
          // انتظر حتى تكتمل عملية تحميل الأصناف من قاعدة البيانات
          await VMExpenseInvoice.EditeAlreadyInvoices(s);
          VMExpenseInvoice.MaxInvoices = s;
          VMExpenseInvoice.Maxjournals = sm;
          AllEmplyess();
          return;
        }

        // الضغطة الثانية: فتح الفاتورة والانتقال للتعديل
        if (_lastTappedId == s && mounted) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ExpenseInvoices()));
          _lastTappedId = null;
        }
      },
      allowSorting: true,
      source: expenseReviewData,
      columns: Columns(),
    );
  }

  List<GridColumn> Columns() {
    return <GridColumn>[
      GridColumn(
        columnName: '_id',
        allowFiltering: true,
        allowSorting: true,
        columnWidthMode: ColumnWidthMode.fitByColumnName,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: const Text(
            '#',
          ),
        ),
      ),
      GridColumn(
          columnName: '_date',
          allowFiltering: true,
          allowSorting: true,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('التاريخ'))),
      GridColumn(
          columnName: '_time',
          allowFiltering: true,
          allowSorting: true,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'الوقت',
                overflow: TextOverflow.ellipsis,
              ))),
      GridColumn(
          columnName: '_account_no',
          allowFiltering: true,
          allowSorting: true,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('رقم الحساب'))),
      GridColumn(
          columnName: '_account_name',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('اسم الحساب'))),
      GridColumn(
          columnName: '_jornal',
          allowFiltering: false,
          allowSorting: true,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('رقم القيد'))),
      GridColumn(
          columnName: '_amount',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('قيمة الفاتورة'))),
      GridColumn(
          columnName: '_disscount',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('قيمة الخصم'))),
      GridColumn(
          columnName: '_amount_all',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('قيمة الفاتورة الكلية'))),
      GridColumn(
          columnName: '_currency',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('عملة الفاتورة'))),
      GridColumn(
          columnName: '_rate',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('قيمة العملة'))),
      GridColumn(
          columnName: '_payment',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('المدفوع'))),
      GridColumn(
          columnName: '_payment_currency',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('عملة المدفوع'))),
      GridColumn(
          columnName: '_remaining',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('المتبقي'))),
      GridColumn(
          columnName: '_discription',
          allowFiltering: false,
          allowSorting: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('الملاحظات'))),
      GridColumn(
        columnName: '_delete',
        allowFiltering: false,
        allowSorting: false,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('حذف'),
        ),
      ),
    ];
  }
}
