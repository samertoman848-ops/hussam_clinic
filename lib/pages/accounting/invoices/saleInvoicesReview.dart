import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../datasource/invoicesReview_datasource.dart';
import '../../../global_var/globals.dart';
import '../../../main.dart';
import '../../../db/accounting/invoices/dbinvoices.dart';
import '../../../widgets/page_transition.dart';
import '../../../theme/app_theme.dart';
import '../../../View_model/ViewModelSalesInvoices.dart';
import '../../../db/patients/dbpatient.dart';
import '../../../model/accounting/AccoutingTreeModel.dart';
import 'SalesInvoices.dart';
import 'SalesInvoicesOptions.dart';

const Color primaryColor = Color(0xffd0d4d7); //corner
const Color accentColor = Color(0xff3f86bd); //background
const TextStyle textStyle = TextStyle(color: Color(0xff7bb05d), fontSize: 14);
const TextStyle textStyleSubItems = TextStyle(color: Colors.grey);

class SaleInvoicesReview extends StatefulWidget {
  const SaleInvoicesReview({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SaleInvoicesReviewState();
  }
}

class SaleInvoicesReviewState extends State<SaleInvoicesReview> {
  late InvoicesReviewDataSource invoicesReviewData;
  final DataGridController _dataGridController = DataGridController();
  String? selectedInvoiceId; // تتبع الفاتورة المختارة
  String? lastTappedInvoiceId; // تتبع آخر فاتورة تم الضغط عليها

  // دالة لتحميل أسماء المرضى من جدول patients مباشرة
  Future<void> _loadAllPatients() async {
    try {
      DbPatient dbPatient = DbPatient();
      final patients = await dbPatient.allPatients();

      // إضافة المرضى إلى قائمة العملاء
      allAccountingCoustmers.clear();
      allAccountingCoustmers_s.clear();

      for (var patient in patients) {
        AccoutingTreeModel tree = AccoutingTreeModel.Valueed(
          patient.id,
          patient.name,
          patient.id.toString(),
          '5200',
          patient.id.toString(),
        );
        allAccountingCoustmers.add(tree);
        if (patient.name.isNotEmpty) {
          allAccountingCoustmers_s.add(patient.name);
        }
      }

      print(
          'تم تحميل ${allAccountingCoustmers_s.length} اسم مريض من جدول patients');
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

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
          allInvoices.removeWhere((inv) => inv.id.toString() == id);
          invoicesReviewData = InvoicesReviewDataSource(
              invoicesData: allInvoices, onDelete: handleDelete);
        });
      }
    }

    setState(() {
      //AllInvioces();
      invoicesReviewData = InvoicesReviewDataSource(
          invoicesData: allInvoices, onDelete: handleDelete);
    });
  }

  // دالة حذف الفاتورة المختارة
  void _deleteSelectedInvoice() async {
    if (selectedInvoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار فاتورة لحذفها'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'حذف الفاتورة',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'هل أنت متأكد من حذف الفاتورة رقم $selectedInvoiceId؟\nسيتم حذفها نهائياً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && selectedInvoiceId != null) {
      try {
        DbInvoices db = DbInvoices();
        await db.deleteInvoice(selectedInvoiceId!);

        setState(() {
          allInvoices
              .removeWhere((inv) => inv.id.toString() == selectedInvoiceId);
          invoicesReviewData = InvoicesReviewDataSource(
            invoicesData: allInvoices,
            onDelete: (ctx, id) async {
              final confirmed = await showDialog<bool>(
                context: ctx,
                builder: (dctx) => AlertDialog(
                  title: const Text('حذف الفاتورة',
                      style: TextStyle(color: Colors.red)),
                  content: const Text(
                      'هل أنت متأكد من حذف هذه الفاتورة؟ سيتم حذفها نهائياً.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dctx, false),
                        child: const Text('إلغاء')),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                  allInvoices.removeWhere((inv) => inv.id.toString() == id);
                });
              }
            },
          );
          selectedInvoiceId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف الفاتورة رقم $selectedInvoiceId بنجاح',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف الفاتورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            'فواتير المبيعات',
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
                    await AllPaitentsTreeList();
                    await _loadAllPatients();
                    VMGlobal.MaxNoS();

                    // إنشاء فاتورة جديدة
                    VMSalesInvoice = ViewModelSalesInvoices.impty();

                    if (mounted) {
                      Navigator.of(context).push(
                        PageTransition(child: const SalesInvoices()),
                      );
                    }
                  },
                ),
              ),
            ),
            // زر حذف الفاتورة المختارة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Tooltip(
                message: 'حذف الفاتورة المختارة',
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: selectedInvoiceId != null
                      ? () => _deleteSelectedInvoice()
                      : null,
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
      editingGestureType: EditingGestureType.doubleTap,
      controller: _dataGridController,
      onCellTap: (DataGridCellTapDetails details) async {
        final rowIdx = details.rowColumnIndex.rowIndex;
        if (rowIdx < 1) return;
        final row = invoicesReviewData.effectiveRows[rowIdx - 1];

        String s = row.getCells()[0].value.toString();
        String sm = row.getCells()[5].value.toString();

        // الضغطة الأولى: تحميل البيانات
        if (lastTappedInvoiceId != s) {
          // فاتورة جديدة: حمّل بيانتها فقط
          setState(() {
            selectedInvoiceId = s;
            lastTappedInvoiceId = s;
          });

          // تحميل الفاتورة والأصناف
          await VMSalesInvoice.EditeAlreadyInvoices(s);

          VMSalesInvoice.MaxInvoices = s;
          VMSalesInvoice.Maxjournals = sm;
          AllEmplyess();

          print('تم تحميل بيانات الفاتورة رقم: $s');
          return;
        }

        // الضغطة الثانية: فتح الفاتورة
        if (lastTappedInvoiceId == s && mounted) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SalesInvoices()));
          lastTappedInvoiceId = null; // إعادة تعيين بعد الفتح
        }
      },
      allowSorting: true,
      source: invoicesReviewData,
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
              child: Text('التاريخ'))),
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
