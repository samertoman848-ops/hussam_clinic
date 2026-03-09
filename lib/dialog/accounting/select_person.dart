import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import '../../pages/accounting/invoices/SalesInvoices.dart';

class SelectPerson extends StatefulWidget {
  final String title;
  const SelectPerson({
    super.key,
    required this.title,
  });

  @override
  State<StatefulWidget> createState() => _SelectPersonState();
}

TextStyle textStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.green,
  fontSize: 20,
);
List<String> persons = [];

void checkValues() {
  if (VMSalesInvoice.AccountingGroups_select == 'المرضي') {
    persons.addAll(allAccountingCoustmers_s);
  } else if (VMSalesInvoice.AccountingGroups_select == 'المورديين') {
    persons.addAll(allAccountingSuppliers_s);
  } else if (VMSalesInvoice.AccountingGroups_select == 'الموظفين') {
    persons.addAll(allAccountingEmployees_s);
  }
}

class _SelectPersonState extends State<SelectPerson> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      persons.clear();
      checkValues();
    });
  }

  void selecedId(String value) {
    if (VMSalesInvoice.AccountingGroups_select == 'المرضي') {
      for (var e in allAccountingCoustmers) {
        if (e.name == value) {
          setState(() {
            VMSalesInvoice.AccountingPerson_select_id = e.branch_no.toString();
          });
        }
      }
    } else if (VMSalesInvoice.AccountingGroups_select == 'المورديين') {
      for (var e in allAccountingSuppliers) {
        if (e.name == value) {
          setState(() {
            VMSalesInvoice.AccountingPerson_select_id = e.branch_no.toString();
          });
        }
      }
    } else if (VMSalesInvoice.AccountingGroups_select == 'الموظفين') {
      for (var e in allAccountingEmployees) {
        if (e.name == value) {
          setState(() {
            VMSalesInvoice.AccountingPerson_select_id = e.branch_no.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          height: 300,
          // Bottom rectangular box
          margin: const EdgeInsets.only(
              top: 10), // to push the box half way below circle
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(
              top: 20, left: 10, right: 12), // spacing inside the box
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "اختار اسم الشخص",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  fit: FlexFit.loose,
                  showSelectedItems: true,
                  showSearchBox: true,
                ),
                items: (filter, loadProps) => persons,
                decoratorProps: DropDownDecoratorProps(
                  baseStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 35,
                    ),
                    labelText: "الاسم ",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                    hintText: "اختار الاسم ",
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    VMSalesInvoice.AccountingPerson_select_name = value!;
                    selecedId(value);
                  });
                  Navigator.of(context).pop();
                },
                //selectedItem: "",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
