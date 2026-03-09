import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import '../../pages/accounting/invoices/SalesInvoices.dart';

class SelectPersonsGroup extends StatefulWidget {
  const SelectPersonsGroup({super.key});
  @override
  State<StatefulWidget> createState() => _SelectPersonsGroupState();
}

TextStyle textStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.green,
  fontSize: 20,
);

class _SelectPersonsGroupState extends State<SelectPersonsGroup> {
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
                'اختار القائمة المطلوبة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: allAccountingContens.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                      onTap: () {
                        setState(() {
                          VMSalesInvoice.AccountingGroups_select =
                              allAccountingContens[index];
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.menu,
                                color: Colors.teal,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                ' قائمة ${allAccountingContens[index]}',
                                style: textStyle,
                              ),
                            ],
                          )));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
