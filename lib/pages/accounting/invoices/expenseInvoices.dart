import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/View_model/ViewModelExpenseInvoices.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/dialog/accounting/select_persons_group.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../../dialog/accounting/select_trees.dart';
import '../../../global_var/globals.dart';
import '../../../main.dart';
import '../../../reports/reportExpenseInvoicePDF.dart';

class ExpenseInvoices extends StatefulWidget {
  const ExpenseInvoices({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ExpenseInvoicesState();
  }
}

var VMExpenseInvoice = ViewModelExpenseInvoices.impty();

class ExpenseInvoicesState extends State<ExpenseInvoices> {
  // حفظ الصفوف في متغير State ثابت لمنع إعادة بنائها عند كل setState
  late List<PlutoRow> _frozenRows;

  @override
  void dispose() {
    super.dispose();
    VMExpenseInvoice.saving = false;
    VMExpenseInvoice.EditeMode = false;
  }

  @override
  void initState() {
    super.initState();
    if (VMExpenseInvoice.EditeMode) {
      // وضع التعديل: لا تُعد الإنشاء ولا تُمسح البيانات، حدّث القوائم فقط
      VMExpenseInvoice.checkValues2();
    } else {
      // فاتورة جديدة: أعد الإنشاء وامسح كل شيء
      VMExpenseInvoice = ViewModelExpenseInvoices.impty();
      VMExpenseInvoice.checkValues();
      VMExpenseInvoice.checkValues2();
    }
    // تجميد نسخة من الصفوف عند الفتح
    _frozenRows = List<PlutoRow>.from(VMExpenseInvoice.rows);
    print('✅ ExpenseInvoices initState: EditeMode=${VMExpenseInvoice.EditeMode}, rows=${_frozenRows.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text(
            'فاتورة شراء',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          actions: BarActions(),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildCustomerCard(),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: tabledata(),
                    ),
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

  /// Widgit
  List<Widget> BarActions() {
    return <Widget>[
      _buildAppBarAction(
        icon: Icons.print_rounded,
        tooltip: 'طباعة الفاتورة',
        onPressed: () {
          setState(() {
            reportExpenseInvoicePDF InvoiceReport = reportExpenseInvoicePDF();
            InvoiceReport.inti();
            InvoiceReport.stateManager = VMExpenseInvoice.stateManager;
          });
        },
      ),
      _buildAppBarAction(
        icon: Icons.delete_sweep_rounded,
        tooltip: 'حذف السطر',
        onPressed: () {
          setState(() {
            VMExpenseInvoice.stateManager.removeCurrentRow();
            VMExpenseInvoice.calculateTotals();
          });
        },
      ),
      _buildAppBarAction(
        icon: Icons.add_box_rounded,
        tooltip: 'إضافة سطر',
        onPressed: () {
          setState(() {
            VMExpenseInvoice.AddNewRecord();
          });
        },
      ),
      _buildAppBarAction(
        icon:
            VMExpenseInvoice.saving ? Icons.edit_document : Icons.save_rounded,
        tooltip: VMExpenseInvoice.saving ? 'تعديل' : 'حفظ',
        onPressed: () => _handleSaveOrEdit(),
      ),
    ];
  }

  Widget _buildAppBarAction(
      {required IconData icon,
      required String tooltip,
      required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      tooltip: tooltip,
      iconSize: 28,
      onPressed: onPressed,
    );
  }

  void _handleSaveOrEdit() {
    setState(() {
      if (VMExpenseInvoice.saving) {
        _showConfirmDialog(
          title: 'تعديل فاتورة الشراء',
          message: 'هل أنت متأكد من حفظ التعديلات؟',
          onConfirm: () async {
            await VMExpenseInvoice.EditeInvoices(VMExpenseInvoice.MaxInvoices);
            _showSuccessSnackBar('تم تعديل الفاتورة بنجاح');
            AllPatientList();
            copyExternalDB();
            if (context.mounted) Navigator.of(context).pop();
          },
        );
      } else {
        _showConfirmDialog(
          title: 'إضافة فاتورة شراء',
          message: 'هل تريد حفظ الفاتورة الجديدة؟',
          onConfirm: () async {
            await VMExpenseInvoice.AddNewInvoices();
            _showSuccessSnackBar('تم إضافة الفاتورة بنجاح');
            copyExternalDB();
            setState(() => VMExpenseInvoice.saving = true);
            if (context.mounted) Navigator.of(context).pop();
          },
        );
      }
    });
  }

  void _showConfirmDialog(
      {required String title,
      required String message,
      required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildInfoItem(
              icon: Icons.confirmation_number_outlined,
              label: 'رقم الفاتورة',
              value: VMExpenseInvoice.Maxjournals.padLeft(6, '0'),
            ),
            const SizedBox(width: 16),
            _buildInteractiveItem(
              icon: Icons.calendar_today_outlined,
              label: 'التاريخ',
              value:
                  '${VMExpenseInvoice.dateDate.year}/${VMExpenseInvoice.dateDate.month}/${VMExpenseInvoice.dateDate.day}',
              onTap: () async {
                final date = await VMExpenseInvoice.pickDate(context);
                if (date != null) {
                  setState(() => VMExpenseInvoice.dateDate = date);
                }
              },
            ),
            const SizedBox(width: 16),
            _buildInteractiveItem(
              icon: Icons.access_time_outlined,
              label: 'الوقت',
              value:
                  '${VMExpenseInvoice.Selectedtime.hour}:${VMExpenseInvoice.Selectedtime.minute}',
              onTap: () async {
                final time = await VMExpenseInvoice.picktime(context);
                if (time != null) {
                  setState(() => VMExpenseInvoice.Selectedtime = time);
                }
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCurrencyDropdown(),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: _buildSummaryInput(
                'سعر التحويل',
                VMExpenseInvoice.rate,
                (val) => setState(
                    () => VMExpenseInvoice.rate = double.tryParse(val) ?? 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
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
                  flex: 2,
                  child: _buildInteractiveItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'الحساب المالي (إلى)',
                    value: VMExpenseInvoice.AccountingTo_select_name,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => const SelectTrees());
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('المورد / الحساب (من)',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blueGrey)),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => SelectPersonsGroup());
                              setState(() {
                                VMExpenseInvoice.AccountingPerson_select_name =
                                    '';
                                VMExpenseInvoice.checkValues2();
                              });
                            },
                            child: Icon(Icons.group_add,
                                size: 20, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          fit: FlexFit.loose,
                          showSelectedItems: true,
                          showSearchBox: true,
                        ),
                        items: (filter, loadProps) => VMExpenseInvoice.persons,
                        selectedItem:
                            VMExpenseInvoice.AccountingPerson_select_name,
                        decoratorProps: DropDownDecoratorProps(
                          baseStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_pin_rounded,
                                color: AppTheme.primaryColor),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: "اختار المورد ",
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              VMExpenseInvoice.AccountingPerson_select_name =
                                  value;
                              VMExpenseInvoice.selecedId(value);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      {required IconData icon, required String label, required dynamic value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value.toString(),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveItem(
      {required IconData icon,
      required String label,
      required String value,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('عملة الفاتورة',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
        const SizedBox(height: 4),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButton<String>(
            value: VMExpenseInvoice.currencySelect,
            underline: const SizedBox(),
            isExpanded: true,
            items: VMExpenseInvoice.currnceyList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => VMExpenseInvoice.currencySelect = value!);
            },
          ),
        ),
      ],
    );
  }

  PlutoGrid tabledata() {
    final localColumns = List<PlutoColumn>.from(VMExpenseInvoice.columns);
    localColumns.add(
      PlutoColumn(
        title: 'حذف',
        field: 'delete',
        width: 80,
        type: PlutoColumnType.text(),
        enableSorting: false,
        renderer: (rendererContext) {
          return IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'حذف السطر',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('حذف السطر',
                      style: TextStyle(color: Colors.red)),
                  content: const Text('هل أنت متأكد من حذف هذا السطر؟'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء')),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          try {
                            VMExpenseInvoice.stateManager
                                .removeRows([rendererContext.row]);
                          } catch (e) {}
                          VMExpenseInvoice.calculateTotals();
                        });
                      },
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    return PlutoGrid(
      columns: localColumns,
      rows: _frozenRows,
      onLoaded: (event) {
        VMExpenseInvoice.stateManager = event.stateManager;
        VMExpenseInvoice.stateManager.setShowColumnFilter(false);
        if (mounted) {
          setState(() {
            VMExpenseInvoice.calculateTotals();
          });
        }
      },
      rowColorCallback: (PlutoRowColorContext rowColorContext) {
        return rowColorContext.row.cells['id']?.value == '0'
            ? const Color(0xFFDABED1)
            : const Color(0xFFE2F6DF);
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        PlutoRow currentRow = VMExpenseInvoice.stateManager.currentRow!;
        VMExpenseInvoice.selecedIndexId(
            currentRow.cells['name']!.value.toString());
        currentRow.cells['id_item']!.value = AccountingIndx_select_id;

        ///Check if price
        if (currentRow.cells['price']!.value == 0) {
          currentRow.cells['price']!.value =
              int.parse(AccountingIndexModel.selling_price);
        }

        ///Check if Qty is Statficed بضاعة
        if (AccountingIndexModel.type == 'بضاعة') {
          if (currentRow.cells['qty']!.value <=
              int.parse(AccountingIndexModel.balance)) {
            currentRow.cells['total']!.value =
                currentRow.cells['price']!.value *
                    currentRow.cells['qty']!.value;
          } else {
            SnackBar snackBar = const SnackBar(
              content: Text(" يجب أن تكون كمية البضاعة أقل من الكمية المصروفة"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            currentRow.cells['qty']!.value =
                int.parse(AccountingIndexModel.balance);
            currentRow.cells['total']!.value =
                currentRow.cells['price']!.value *
                    currentRow.cells['qty']!.value;
          }
        } else {
          currentRow.cells['total']!.value =
              currentRow.cells['price']!.value * currentRow.cells['qty']!.value;
        }

        // Use addPostFrameCallback to avoid "setState() called when widget tree was locked"
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              VMExpenseInvoice.calculateTotals();
            });
          }
        });
      },
      configuration: const PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          resizeMode: PlutoResizeMode.pushAndPull,
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
        localeText: PlutoGridLocaleText.arabic(),
        enableMoveHorizontalInEditing: true,
        style: PlutoGridStyleConfig(
          checkedColor: Color(0x11757575),
          evenRowColor: Colors.white12,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildSummaryInput('الخصم', VMExpenseInvoice.disscount, (val) {
                  setState(() {
                    VMExpenseInvoice.disscount = double.tryParse(val) ?? 0.0;
                    VMExpenseInvoice.calculateTotals();
                  });
                }),
                const SizedBox(width: 12),
                _buildSummaryInput('دفع كاش', VMExpenseInvoice.payment, (val) {
                  setState(() {
                    VMExpenseInvoice.payment = double.tryParse(val) ?? 0.0;
                    VMExpenseInvoice.calculateTotals();
                  });
                }),
                const SizedBox(width: 12),
                _buildSummaryInput('دفع تطبيق', VMExpenseInvoice.payment_app,
                    (val) {
                  setState(() {
                    VMExpenseInvoice.payment_app = double.tryParse(val) ?? 0.0;
                    VMExpenseInvoice.calculateTotals();
                  });
                }),
                _buildPaymentCurrencyDropdown(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTotalBlock('مجموع الفاتورة', VMExpenseInvoice.amount,
                    AppTheme.primaryColor),
                const SizedBox(width: 12),
                _buildTotalBlock('الإجمالي النهائي',
                    VMExpenseInvoice.amount_all, const Color(0xFF1D9D99)),
                const SizedBox(width: 12),
                _buildTotalBlock('المبلغ المتبقي', VMExpenseInvoice.remaining,
                    Colors.orange[800]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInput(
      String label, double initialValue, Function(String) onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: initialValue.toString(),
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.grey[100],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCurrencyDropdown() {
    return Column(
      children: [
        const Text('عملة الدفع',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButton<String>(
            value: VMExpenseInvoice.payment_currency,
            underline: const SizedBox(),
            items: VMExpenseInvoice.currnceyList.map((String value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)));
            }).toList(),
            onChanged: (value) {
              setState(() => VMExpenseInvoice.payment_currency = value!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBlock(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '${value.toStringAsFixed(2)} ${VMExpenseInvoice.currencySelect}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
