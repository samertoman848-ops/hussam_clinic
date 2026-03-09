import 'package:flutter/material.dart';
import 'package:hussam_clinc/model/accounting/journals/journalsModel.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class JournalsReviewDataSource extends DataGridSource {
  JournalsReviewDataSource({required List<JournalsModel> journalsModel}) {
    _journalsData  =
        journalsModel
            .map<DataGridRow>((e) => DataGridRow(cells: [
          DataGridCell<int>(columnName: 'id', value:e.id),
          DataGridCell<String>(columnName: 'date',value:'${DateTime.parse(e.date).day}/${DateTime.parse(e.date).month}/${DateTime.parse(e.date).year}'),
          DataGridCell<String>(columnName: 'time', value: e.time),
          DataGridCell<String>(columnName: 'discription', value: e.discription),
          DataGridCell<String>(columnName: 'amount', value: e.amount),
          DataGridCell<String>(columnName: 'currency', value: e.currency),
          DataGridCell<String>(columnName: 'rate', value: e.rate),
          DataGridCell<String>(columnName: 'ry', value:  (double.parse(e.amount)*double.parse(e.rate)).toString()),

        ]))
            .toList();
  }

  List<DataGridRow> _journalsData  = [];

  @override
  List<DataGridRow> get rows => _journalsData ;


  // @override
  // Widget? buildTableSummaryCellWidget(
  //     GridTableSummaryRow summaryRow,
  //     GridSummaryColumn? summaryColumn,
  //     RowColumnIndex rowColumnIndex,
  //     String summaryValue) {
  //   return Container(
  //     padding: const EdgeInsets.all(15.0),
  //     child: Text(summaryValue),
  //   );
  // }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    /// get colors
    Color getRowBackgroundColor() {
      final String curancy = row.getCells()[5].value;
      if (curancy == 'شيكل') {
        return Colors.white12;
      } else if (curancy == 'دولار') {
        return Colors.pinkAccent[100]!;
      }else
      {
        return Colors.white12;
      }
    }
    TextStyle? getTextStyle() {
      final String curancy = row.getCells()[5].value;
      if (curancy == 'شيكل') {
        return const TextStyle(color:Colors.teal ,fontSize:16);
      } else if (curancy == 'دولار') {
        return const TextStyle(color:Colors.white ,fontSize:16);
      }else
      {
        return const TextStyle(color: Colors. pinkAccent,fontSize:16);
      }
    }
    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          late String cellValue;

          cellValue = e.value.toString();
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(cellValue.toString(),
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(),
            ),
          );
        }).toList());
  }
}