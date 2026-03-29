import 'package:flutter/material.dart';
import 'package:hussam_clinc/model/accounting/journals/journalsModel.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class JournalsReviewDataSource extends DataGridSource {
  final Function(BuildContext context, String id)? onEdit;
  final Function(BuildContext context, String id)? onDelete;

  JournalsReviewDataSource({
    required List<JournalsModel> journalsModel,
    this.onEdit,
    this.onDelete,
  }) {
    _journalsData = journalsModel
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: '_id', value: e.id),
              DataGridCell<String>(
                  columnName: '_date',
                  value: _formatDate(e.date)),
              DataGridCell<String>(columnName: '_time', value: e.time),
              DataGridCell<String>(columnName: '_discription', value: e.discription),
              DataGridCell<String>(columnName: '_amount', value: e.amount),
              DataGridCell<String>(columnName: '_currency', value: e.currency),
              DataGridCell<String>(columnName: '_rate', value: e.rate),
              DataGridCell<String>(
                  columnName: '_ry',
                  value: (double.parse(e.amount) * double.parse(e.rate)).toString()),
              DataGridCell<String>(columnName: '_edit', value: ''),
              DataGridCell<String>(columnName: '_delete', value: ''),
            ]))
        .toList();
  }

  List<DataGridRow> _journalsData = [];

  @override
  List<DataGridRow> get rows => _journalsData;

  String _formatDate(String dateStr) {
    try {
      if (dateStr.contains('/')) {
        return dateStr.split(' ')[0]; // Already formatted dd/MM/yyyy
      }
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      final String currency = row.getCells()[5].value;
      if (currency == 'شيكل') return Colors.white12;
      if (currency == 'دولار') return Colors.pinkAccent[100]!;
      return Colors.white12;
    }

    TextStyle getTextStyle() {
      final String currency = row.getCells()[5].value;
      if (currency == 'شيكل') return const TextStyle(color: Colors.teal, fontSize: 16);
      if (currency == 'دولار') return const TextStyle(color: Colors.white, fontSize: 16);
      return const TextStyle(color: Colors.pinkAccent, fontSize: 16);
    }

    return DataGridRowAdapter(
      color: getRowBackgroundColor(),
      cells: row.getCells().map<Widget>((e) {
        // زر التعديل
        if (e.columnName == '_edit') {
          final id = row.getCells()[0].value.toString();
          return Builder(builder: (ctx) {
            return IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              tooltip: 'تعديل القيد',
              onPressed: () {
                if (onEdit != null) onEdit!(ctx, id);
              },
            );
          });
        }

        // زر الحذف
        if (e.columnName == '_delete') {
          final id = row.getCells()[0].value.toString();
          return Builder(builder: (ctx) {
            return IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'حذف القيد وكل ما يرتبط به',
              onPressed: () {
                if (onDelete != null) onDelete!(ctx, id);
              },
            );
          });
        }

        // بقية الخلايا
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            e.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(),
          ),
        );
      }).toList(),
    );
  }
}