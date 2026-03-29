import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/dbindex.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PageItemReport extends StatefulWidget {
  const PageItemReport({super.key});

  @override
  State<PageItemReport> createState() => _PageItemReportState();
}

class _PageItemReportState extends State<PageItemReport> {
  List<Map<String, dynamic>> allItems = [];
  bool isLoading = true;
  late ItemReportDataSource _dataSource;
  String selectedWarehouse = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    DbIndex db = DbIndex();
    final items = await db.getItemsReport();
    if (mounted) {
      setState(() {
        allItems = items;
        _updateDataSource();
        isLoading = false;
      });
    }
  }

  void _updateDataSource() {
    var filtered = allItems;
    if (selectedWarehouse != 'الكل') {
      filtered = filtered.where((e) => e['warehouse'] == selectedWarehouse).toList();
    }
    _dataSource = ItemReportDataSource(items: filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D9D99),
          title: const Text('تقرير جرد الأصناف / المخازن', style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('تصفية حسب المخزن: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedWarehouse,
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                      items: ['الكل', 'مخزن للزراعة', 'مخزن لباقي العيادة'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedWarehouse = newValue!;
                          _updateDataSource();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SfDataGridTheme(
                      data: SfDataGridThemeData(
                        headerColor: const Color(0xff009889),
                      ),
                      child: SfDataGrid(
                        source: _dataSource,
                        allowFiltering: true,
                        allowSorting: true,
                        columnWidthMode: ColumnWidthMode.fill,
                        columns: <GridColumn>[
                          GridColumn(
                            columnName: '_no',
                            label: Container(
                              alignment: Alignment.center,
                              child: const Text('#', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            width: 60,
                          ),
                          GridColumn(
                            columnName: '_name',
                            label: Container(
                              alignment: Alignment.center,
                              child: const Text('اسم الصنف / المقاس / التفاصيل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: '_warehouse',
                            label: Container(
                              alignment: Alignment.center,
                              child: const Text('المخزن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: '_ini',
                            label: Container(
                              alignment: Alignment.center,
                              child: const Text('أول المدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: '_in',
                            label: Container(
                              alignment: Alignment.center,
                              child: const Text('الوارد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: '_out',
                            label: Container(
                              alignment: Alignment.center,
                              child: const Text('الصادر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridColumn(
                            columnName: '_balance',
                            label: Container(
                              alignment: Alignment.center,
                              child: const Text('المتبقي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemReportDataSource extends DataGridSource {
  ItemReportDataSource({required List<Map<String, dynamic>> items}) {
    _items = items.map<DataGridRow>((e) {
      double ini = e['initial_balance'] ?? 0.0;
      double tin = e['total_in'] ?? 0.0;
      double tout = e['total_out'] ?? 0.0;
      double balance = ini + tin - tout;

      return DataGridRow(cells: [
        DataGridCell<int>(columnName: '_no', value: e['index_no']),
        DataGridCell<String>(columnName: '_name', value: e['index_name']),
        DataGridCell<String>(columnName: '_warehouse', value: e['warehouse'] == 'الوصف' || e['warehouse'] == null || e['warehouse'].toString().isEmpty ? 'غير محدد' : e['warehouse']),
        DataGridCell<double>(columnName: '_ini', value: ini),
        DataGridCell<double>(columnName: '_in', value: tin),
        DataGridCell<double>(columnName: '_out', value: tout),
        DataGridCell<double>(columnName: '_balance', value: balance),
      ]);
    }).toList();
  }

  List<DataGridRow> _items = [];

  @override
  List<DataGridRow> get rows => _items;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
    );
  }
}
