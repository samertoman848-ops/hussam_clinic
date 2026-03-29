import 'package:flutter/material.dart';
import 'package:hussam_clinc/model/accounting/VoucherModel.dart';
import 'package:hussam_clinc/db/patients/dbpatient.dart';
import 'package:hussam_clinc/pages/costumer/PageEditCostumers.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class VouchersReviewDataSource extends DataGridSource {
  final void Function(BuildContext context, int id)? onDelete;

  VouchersReviewDataSource({required List<VoucherModel> vouchersData, this.onDelete}) {
    _vouchersData = vouchersData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'date', value: e.date),
              DataGridCell<String>(columnName: 'time', value: e.time),
              DataGridCell<String>(columnName: 'account', value: e.account),
              DataGridCell<String>(columnName: 'dealer', value: e.dealer),
              DataGridCell<String>(columnName: 'patient_link', value: e.account),
              DataGridCell<String>(columnName: 'journal', value: e.jornal),
              DataGridCell<String>(columnName: 'payment', value: e.payment),
              DataGridCell<String>(columnName: 'currency', value: e.currency),
              DataGridCell<String>(columnName: 'class', value: e.className),
              DataGridCell<String>(columnName: 'description', value: e.discription),
              DataGridCell<String>(columnName: '_delete', value: ''),
            ]))
        .toList();
  }

  List<DataGridRow> _vouchersData = [];

  @override
  List<DataGridRow> get rows => _vouchersData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'patient_link') {
        final accountNo = e.value.toString();
        return Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.person_search, color: Colors.blue),
            tooltip: 'فتح ملف المريض',
            onPressed: () async {
              final db = DbPatient();
              final patientFile = await db.getPatientByFileNo(accountNo);
              if (patientFile != null && ctx.mounted) {
                Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (c) => PageEditCostumers(patientFile, initialIndex: 6)));
                return;
              }
              final idInt = int.tryParse(accountNo);
              if (idInt != null) {
                final patientById = await db.getPatientById(idInt);
                if (patientById != null && ctx.mounted) {
                  Navigator.push(
                      ctx,
                      MaterialPageRoute(
                          builder: (c) => PageEditCostumers(patientById, initialIndex: 6)));
                  return;
                }
              }
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('المريض غير موجود')));
              }
            },
          );
        });
      }
      if (e.columnName == '_delete') {
        final id = row.getCells()[0].value as int;
        return Builder(builder: (ctx) {
          return IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'حذف السند',
            onPressed: () {
              if (onDelete != null) {
                onDelete!(ctx, id);
              }
            },
          );
        });
      }
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          e.value.toString(),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.teal, fontSize: 14),
        ),
      );
    }).toList());
  }
}
