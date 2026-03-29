import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/dbindex.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/model/accounting/journals/IndexModel.dart';
import 'package:hussam_clinc/main.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PageItems extends StatefulWidget {
  const PageItems({super.key});

  @override
  State<PageItems> createState() => _PageItemsState();
}

class _PageItemsState extends State<PageItems> {
  List<IndexModel> items = [];
  bool isLoading = true;
  late ItemDataSource _itemDataSource;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await AllAccountingIndexList(); // refresh global 
    setState(() {
      items = List.from(allAccountingIndex);
      _itemDataSource = ItemDataSource(
        items: items,
        onEdit: (item) => _showAddEditDialog(context, itemToEdit: item),
        onDelete: (item) => _deleteItem(item),
      );
      isLoading = false;
    });
  }

  void _showAddEditDialog(BuildContext context, {IndexModel? itemToEdit}) {
    final bool isEdit = itemToEdit != null;
    final TextEditingController nameController = TextEditingController(text: isEdit ? itemToEdit.name : '');
    final TextEditingController priceController = TextEditingController(text: isEdit ? itemToEdit.selling_price : '0');
    final TextEditingController typeController = TextEditingController(text: isEdit ? itemToEdit.type : 'بضاعة -عمل');
    final TextEditingController initialBalanceController = TextEditingController(text: isEdit ? itemToEdit.ini_balance : '0');
    
    String selectedWarehouse = isEdit && itemToEdit.description.isNotEmpty && itemToEdit.description != 'الوصف' 
        ? itemToEdit.description 
        : 'مخزن لباقي العيادة';

    showDialog(
      context: context,
      builder: (BuildContext dctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(isEdit ? 'تعديل الصنف' : 'إضافة صنف جديد'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'اسم الصنف/الخدمة', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: typeController,
                        decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'سعر البيع', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: initialBalanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'رصيد أول المدة', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedWarehouse,
                        decoration: const InputDecoration(labelText: 'المخزن', border: OutlineInputBorder()),
                        items: ['مخزن للزراعة', 'مخزن لباقي العيادة'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setStateDialog(() {
                            selectedWarehouse = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dctx),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) return;
                      
                      DbIndex db = DbIndex();
                      if (isEdit) {
                        itemToEdit.name = nameController.text.trim();
                        itemToEdit.selling_price = priceController.text.trim();
                        itemToEdit.type = typeController.text.trim();
                        itemToEdit.ini_balance = initialBalanceController.text.trim();
                        itemToEdit.description = selectedWarehouse;
                        await db.updateIndex(itemToEdit);
                      } else {
                        int maxNo = await db.getMaxIndexNo();
                        final newItem = IndexModel({
                          "index_no": maxNo,
                          "index_name": nameController.text.trim(),
                          "index_description": selectedWarehouse,
                          "index_type": typeController.text.trim(),
                          "index_unit_name": "وحدة",
                          "index_balance": "0",
                          "index_min_qty": "0",
                          "index_max_qty": "0",
                          "index_selling_price": priceController.text.trim(),
                          "index_selling_currency": "شيكل",
                          "index_buying_price": "0",
                          "index_buying_currency": "شيكل",
                          "index_last_tran_date": DateTime.now().toString(),
                          "index_ini_balance": initialBalanceController.text.trim(),
                        });
                        await db.addIndex(newItem);
                      }
                      
                      if (mounted) Navigator.pop(dctx);
                      _loadData(); // reload
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _deleteItem(IndexModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الصنف', style: TextStyle(color: Colors.red)),
          content: Text('هل أنت متأكد من حذف الصنف [${item.name}]؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dctx, true),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      DbIndex db = DbIndex();
      await db.deleteIndex(item.no);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D9D99),
          title: const Text('الأصناف (الخدمات والمنتجات)', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              tooltip: 'إضافة صنف',
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
              onPressed: () => _showAddEditDialog(context),
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SfDataGridTheme(
                data: SfDataGridThemeData(
                  headerColor: const Color(0xFF1D9D99).withOpacity(0.8),
                ),
                child: SfDataGrid(
                  source: _itemDataSource,
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
                      width: 80,
                    ),
                    GridColumn(
                      columnName: '_name',
                      label: Container(
                        alignment: Alignment.center,
                        child: const Text('اسم الصنف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    GridColumn(
                      columnName: '_type',
                      label: Container(
                        alignment: Alignment.center,
                        child: const Text('النوع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      columnName: '_price',
                      label: Container(
                        alignment: Alignment.center,
                        child: const Text('سعر البيع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    GridColumn(
                      columnName: '_edit',
                      label: Container(
                        alignment: Alignment.center,
                        child: const Text('تعديل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      width: 80,
                      allowFiltering: false,
                      allowSorting: false,
                    ),
                    GridColumn(
                      columnName: '_delete',
                      label: Container(
                        alignment: Alignment.center,
                        child: const Text('حذف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      width: 80,
                      allowFiltering: false,
                      allowSorting: false,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ItemDataSource extends DataGridSource {
  ItemDataSource({
    required List<IndexModel> items,
    required this.onEdit,
    required this.onDelete,
  }) {
    _items = items.map<DataGridRow>((e) => DataGridRow(cells: [
          DataGridCell<int>(columnName: '_no', value: e.no),
          DataGridCell<String>(columnName: '_name', value: e.name),
          DataGridCell<String>(columnName: '_type', value: e.type),
          DataGridCell<String>(columnName: '_warehouse', value: e.description),
          DataGridCell<String>(columnName: '_ini', value: e.ini_balance),
          DataGridCell<String>(columnName: '_price', value: e.selling_price),
          DataGridCell<IndexModel>(columnName: '_edit', value: e),
          DataGridCell<IndexModel>(columnName: '_delete', value: e),
        ])).toList();
  }

  List<DataGridRow> _items = [];
  final Function(IndexModel) onEdit;
  final Function(IndexModel) onDelete;

  @override
  List<DataGridRow> get rows => _items;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == '_edit') {
          return IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(dataGridCell.value as IndexModel),
          );
        } else if (dataGridCell.columnName == '_delete') {
          return IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(dataGridCell.value as IndexModel),
          );
        }
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
