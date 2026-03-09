import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/View_model/ViewModelSalesInvoices.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/dialog/accounting/select_persons_group.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../../dialog/accounting/select_trees.dart';
import '../../../global_var/globals.dart';
import '../../../main.dart';
import '../../../reports/reportSalesInvoicePDF.dart';

class SalesInvoices extends StatefulWidget {
  const SalesInvoices({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SalesInvoicesState();
  }
}

var VMSalesInvoice = ViewModelSalesInvoices.impty();

class SalesInvoicesState extends State<SalesInvoices> {
  @override
  void dispose() {
    super.dispose();
    VMSalesInvoice.saving = false;
  }

  @override
  void initState() {
    super.initState();
    // عند فتح صفحة الفاتورة
    // تأكد من تحديث قوائم الأشخاص والحسابات
    if (!VMSalesInvoice.EditeMode) {
      // إذا كانت فاتورة جديدة، امسح البيانات
      VMSalesInvoice.checkValues();
      VMSalesInvoice.checkValues2();
    } else {
      // إذا كانت فاتورة قديمة للتعديل، حدث القوائم فقط
      VMSalesInvoice.checkValues2();
    }

    print('✅ تم تحميل الفاتورة بـ ${VMSalesInvoice.rows.length} صنف');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('فاتورة بيع'),
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
                      height: 200, // Reduced height to half (from 400 to 200)
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
                label: 'رقم الفاتورة',
                value: VMSalesInvoice.Maxjournals,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInteractiveItem(
                icon: Icons.calendar_today_outlined,
                label: 'التاريخ',
                value:
                    '${VMSalesInvoice.dateDate.year}/${VMSalesInvoice.dateDate.month}/${VMSalesInvoice.dateDate.day}',
                onTap: () async {
                  final date = await VMSalesInvoice.pickDate(context);
                  if (date != null) {
                    setState(() => VMSalesInvoice.dateDate = date);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInteractiveItem(
                icon: Icons.access_time_outlined,
                label: 'الوقت',
                value:
                    '${VMSalesInvoice.Selectedtime.hour}:${VMSalesInvoice.Selectedtime.minute}',
                onTap: () async {
                  final time = await VMSalesInvoice.picktime(context);
                  if (time != null) {
                    setState(() => VMSalesInvoice.Selectedtime = time);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildCurrencyDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildRateField()),
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
                    label: 'الحساب المالي (من)',
                    value: VMSalesInvoice.AccountingTo_select_name,
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
                          Text('العميل / المريض (إلى)',
                              style: VMSalesInvoice.textStyleLabel),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SelectPersonsGroup();
                                  });
                              setState(() {
                                VMSalesInvoice.AccountingPerson_select_name =
                                    '';
                                VMSalesInvoice.checkValues2();
                              });
                            },
                            child: Icon(Icons.group_add,
                                size: 20, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          fit: FlexFit.loose,
                          showSelectedItems: true,
                          showSearchBox: true,
                        ),
                        items: (filter, loadProps) => VMSalesInvoice.persons,
                        selectedItem:
                            VMSalesInvoice.AccountingPerson_select_name,
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
                            hintText: "اختار الاسم ",
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              VMSalesInvoice.AccountingPerson_select_name =
                                  value;
                              VMSalesInvoice.selecedId(value);
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
      {required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 4),
            Text(label, style: VMSalesInvoice.textStyleLabel),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: VMSalesInvoice.textStyle),
      ],
    );
  }

  Widget _buildInteractiveItem(
      {required IconData icon,
      required String label,
      required String value,
      required VoidCallback onTap}) {
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
                Text(label, style: VMSalesInvoice.textStyleLabel),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: VMSalesInvoice.textStyle
                    .copyWith(color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('عملة الفاتورة', style: VMSalesInvoice.textStyleLabel),
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
              value: VMSalesInvoice.currencySelect,
              isExpanded: true,
              items: VMSalesInvoice.currnceyList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => VMSalesInvoice.currencySelect = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('سعر التحويل', style: VMSalesInvoice.textStyleLabel),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: TextFormField(
            initialValue: VMSalesInvoice.rate.toString(),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              final r = double.tryParse(val);
              if (r != null) setState(() => VMSalesInvoice.rate = r);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                _buildSummaryItem('إجمالي الفاتورة',
                    '${VMSalesInvoice.amount} ${VMSalesInvoice.currencySelect}'),
                _buildSummaryInput('الخصم', VMSalesInvoice.disscount, (val) {
                  setState(() {
                    VMSalesInvoice.disscount = double.tryParse(val) ?? 0;
                    VMSalesInvoice.amount_all =
                        VMSalesInvoice.amount - VMSalesInvoice.disscount;
                    VMSalesInvoice.remaining = VMSalesInvoice.amount_all -
                        (VMSalesInvoice.payment + VMSalesInvoice.payment_app);
                  });
                }),
                _buildSummaryInput('دفع كاش', VMSalesInvoice.payment, (val) {
                  setState(() {
                    VMSalesInvoice.payment = double.tryParse(val) ?? 0;
                    VMSalesInvoice.remaining = VMSalesInvoice.amount_all -
                        (VMSalesInvoice.payment + VMSalesInvoice.payment_app);
                  });
                }),
                _buildSummaryInput('دفع تطبيق', VMSalesInvoice.payment_app,
                    (val) {
                  setState(() {
                    VMSalesInvoice.payment_app = double.tryParse(val) ?? 0;
                    VMSalesInvoice.remaining = VMSalesInvoice.amount_all -
                        (VMSalesInvoice.payment + VMSalesInvoice.payment_app);
                  });
                }),
                _buildPaymentCurrencyDropdown(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTotalDisplay('الإجمالي النهائي',
                    VMSalesInvoice.amount_all, Colors.blue[700]!),
                _buildTotalDisplay('المبلـغ المتبقي', VMSalesInvoice.remaining,
                    AppTheme.accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryInput(
      String label, double initialValue, Function(String) onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: TextFormField(
                initialValue: initialValue.toString(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
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
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: VMSalesInvoice.payment_currency,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              items: VMSalesInvoice.currnceyList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => VMSalesInvoice.payment_currency = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalDisplay(String label, double value, Color color) {
    final isNegative = value < 0;
    final displayColor = isNegative ? Colors.red[700]! : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isNegative
            ? Border.all(color: Colors.red[300]!, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          if (isNegative)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.warning_amber_rounded,
                  color: Colors.red[700], size: 18),
            ),
          Text('$label : ',
              style: TextStyle(
                  color: displayColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Text(
            '${value.toStringAsFixed(2)} ${VMSalesInvoice.currencySelect}',
            style: TextStyle(
                color: displayColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> BarActions() {
    return <Widget>[
      _buildAppBarAction(
        icon: Icons.print_outlined,
        tooltip: 'طباعة الفاتورة',
        onPressed: () async {
          _showToast('جاري إنشاء الفاتورة... يرجى الانتظار', Colors.orange);
          reportSalesInvoicePDF InvoiceReport = reportSalesInvoicePDF();
          InvoiceReport.stateManager = VMSalesInvoice.stateManager;
          await InvoiceReport.inti();
          _showToast('تم إنشاء الفاتورة بنجاح وجاري فتحها', Colors.green);
        },
      ),
      _buildAppBarAction(
        icon: Icons.delete_outline_rounded,
        tooltip: 'حذف المنتج المختار',
        onPressed: () {
          _showConfirmDialog(
            title: 'حذف السطر',
            message: 'هل أنت متأكد من حذف السطر المحدد من الفاتورة؟',
            color: Colors.red,
            onConfirm: () async {
              setState(() {
                try {
                  VMSalesInvoice.stateManager.removeCurrentRow();
                } catch (e) {
                  // ignore if no row selected
                }
                // Recalculate totals after deletion
                VMSalesInvoice.amount = 0;
                for (var e in VMSalesInvoice.stateManager.rows) {
                  VMSalesInvoice.amount += e.cells['total']!.value as num;
                }
                VMSalesInvoice.amount_all =
                    VMSalesInvoice.amount - VMSalesInvoice.disscount;
                VMSalesInvoice.remaining = VMSalesInvoice.amount_all -
                    (VMSalesInvoice.payment + VMSalesInvoice.payment_app);
              });
            },
          );
        },
      ),
      _buildAppBarAction(
        icon: Icons.add_circle_outline_rounded,
        tooltip: 'إضافة منتج جديد',
        onPressed: () {
          setState(() => VMSalesInvoice.AddNewRecord());
        },
      ),
      _buildAppBarAction(
        icon: VMSalesInvoice.saving ? Icons.edit_note : Icons.save_rounded,
        tooltip: VMSalesInvoice.saving ? 'تعديل الفاتورة' : 'حفظ الفاتورة',
        onPressed: () {
          setState(() {
            if (VMSalesInvoice.saving) {
              _showConfirmDialog(
                title: 'تعديل الفاتورة',
                message: 'هل أنت متأكد من تعديل بيانات هذه الفاتورة؟',
                color: Colors.blue,
                onConfirm: () async {
                  // استخدم رقم الفاتورة من invoicesModelEdite عند التعديل
                  final invoiceId =
                      VMSalesInvoice.invoicesModelEdite.id.toString();
                  await VMSalesInvoice.EditeInvoices(invoiceId);
                  _showToast(
                      'تم تعديل الفاتورة رقم $invoiceId بنجاح', Colors.blue);
                  AllPatientList();
                  copyExternalDB();
                },
              );
            } else {
              _showConfirmDialog(
                title: 'حفظ الفاتورة',
                message: 'هل أنت متأكد من إضافة هذه الفاتورة للنظام؟',
                color: Colors.green,
                onConfirm: () async {
                  VMSalesInvoice.AddNewInvoices();
                  _showToast('تم حفظ الفاتورة بنجاح', Colors.green);
                  AllPatientList();
                  copyExternalDB();
                  setState(() => VMSalesInvoice.saving = true);
                },
              );
            }
          });
        },
      ),
    ];
  }

  Widget _buildAppBarAction(
      {required IconData icon,
      required String tooltip,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  void _showConfirmDialog(
      {required String title,
      required String message,
      required Color color,
      required Future<void> Function() onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: color)),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  PlutoGrid tabledata() {
    // create a local columns list so we can append a delete column with a renderer
    final localColumns = List<PlutoColumn>.from(VMSalesInvoice.columns);
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
                            VMSalesInvoice.stateManager
                                .removeRows([rendererContext.row]);
                          } catch (e) {}
                          VMSalesInvoice.amount = 0;
                          for (var e in VMSalesInvoice.stateManager.rows) {
                            final v = e.cells['total']?.value;
                            if (v is num) {
                              VMSalesInvoice.amount += v.toDouble();
                            } else if (v is String)
                              VMSalesInvoice.amount += double.tryParse(v) ?? 0;
                          }
                          VMSalesInvoice.amount_all =
                              VMSalesInvoice.amount - VMSalesInvoice.disscount;
                          VMSalesInvoice.remaining = VMSalesInvoice.amount_all -
                              (VMSalesInvoice.payment +
                                  VMSalesInvoice.payment_app);
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
      rows: VMSalesInvoice.rows,
      onLoaded: (event) {
        VMSalesInvoice.stateManager = event.stateManager;
        VMSalesInvoice.stateManager.setShowColumnFilter(false);
      },
      rowColorCallback: (PlutoRowColorContext rowColorContext) {
        return rowColorContext.row.cells['id']?.value == '0'
            ? Colors.blueGrey[50]!
            : Colors.white;
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        PlutoRow currentRow = VMSalesInvoice.stateManager.currentRow!;
        VMSalesInvoice.selecedIndexId(
            currentRow.cells['name']!.value.toString());
        currentRow.cells['id_item']!.value = AccountingIndx_select_id;

        if (currentRow.cells['price']!.value == 0) {
          currentRow.cells['price']!.value =
              int.parse(AccountingIndexModel.selling_price);
        }

        if (AccountingIndexModel.type == 'بضاعة') {
          if (currentRow.cells['qty']!.value <=
              int.parse(AccountingIndexModel.balance)) {
            currentRow.cells['total']!.value =
                currentRow.cells['price']!.value *
                    currentRow.cells['qty']!.value;
          } else {
            _showToast(
                "يجب أن تكون الكمية أقل من المتوفر في المخزن", Colors.orange);
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

        VMSalesInvoice.amount = 0;
        for (var e in VMSalesInvoice.stateManager.rows) {
          VMSalesInvoice.amount += e.cells['total']!.value;
        }
        setState(() {
          VMSalesInvoice.amount_all =
              VMSalesInvoice.amount - VMSalesInvoice.disscount;
          VMSalesInvoice.remaining = VMSalesInvoice.amount_all -
              (VMSalesInvoice.payment + VMSalesInvoice.payment_app);
        });
      },
      configuration: PlutoGridConfiguration(
        columnSize: const PlutoGridColumnSizeConfig(
          resizeMode: PlutoResizeMode.pushAndPull,
          autoSizeMode: PlutoAutoSizeMode.scale,
        ),
        localeText: const PlutoGridLocaleText.arabic(),
        enableMoveHorizontalInEditing: true,
        style: PlutoGridStyleConfig(
          borderColor: Colors.grey[300]!,
          gridBorderColor: Colors.grey[200]!,
          activatedColor: AppTheme.primaryColor.withOpacity(0.05),
          columnTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
