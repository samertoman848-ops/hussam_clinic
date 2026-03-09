import 'package:flutter/material.dart';
import 'package:hussam_clinc/datasource/journalsReview_datasource.dart';
import 'package:hussam_clinc/pages/accounting/journals/journalsPage.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../../global_var/globals.dart';
import '../../../main.dart';

const Color primaryColor = Color(0xffd0d4d7); //corner
const Color accentColor = Color(0xff3f86bd); //background
const TextStyle textStyle = TextStyle(color:  Color(0xff7bb05d),fontSize: 14);
const TextStyle textStyleSubItems = TextStyle(color: Colors.grey);

class JournalsReview extends StatefulWidget{
  const JournalsReview({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return JournalsReviewState();
  }
}

class JournalsReviewState extends State<JournalsReview> {

  late JournalsReviewDataSource journalsReviewDataSource ;
  final DataGridController _dataGridController = DataGridController();

  @override
  void initState() {
    super.initState();
    setState(() {
      journalsReviewDataSource = JournalsReviewDataSource(journalsModel: allJournals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1D9D99),
            title: const Text(
              'القيود المحاسبية',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
          body:
          SfDataGridTheme(
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
      allowColumnsResizing:true,
      allowFiltering: true,
      navigationMode: GridNavigationMode.cell,
      columnWidthMode: ColumnWidthMode.auto,
      rowsPerPage: 30,
      editingGestureType: EditingGestureType.tap,
      controller: _dataGridController,
      onCellTap: (DataGridCellTapDetails details) {
        if (details.rowColumnIndex.rowIndex >= 1 ||
            details.rowColumnIndex.rowIndex <= allEmployees.length ) {
          setState(() {
            String s= journalsReviewDataSource
                .effectiveRows[details.rowColumnIndex.rowIndex-1 ]
                .getCells()[0]
                .value
                .toString();
            VMJournals.EditeAlreadyJournals(s);
            VMJournals.MaxInvoices=s;
            String sm= journalsReviewDataSource
                .effectiveRows[details.rowColumnIndex.rowIndex-1 ]
                .getCells()[5]
                .value
                .toString();
            VMJournals.Maxjournals=sm;
            AllEmplyess();
          });
          Future.delayed(const Duration(seconds: 1)).then((value) {
            Navigator.of(context) .push(MaterialPageRoute(builder: (context) =>  const JournalsPage()));
          });
        }
      },
      allowSorting: true,
      source: journalsReviewDataSource,
      columns: columns(),
    );
  }

  List<GridColumn> columns(){
    return <GridColumn>[
      GridColumn(
        columnName: '_id',
        allowFiltering : true,
        allowSorting : true,
        columnWidthMode : ColumnWidthMode.fitByColumnName,
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
          allowFiltering : true,
          allowSorting : true,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('التاريخ'))),
      GridColumn(
          columnName: '_time',
          allowFiltering : false,
          allowSorting : false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'الوقت',
                overflow: TextOverflow.ellipsis,
              ))),
      GridColumn(
          columnName: '_discription',
          allowFiltering : true,
          allowSorting : false,
          minimumWidth:200 ,
          width : 300,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('البيان'))),
      GridColumn(
          columnName: '_amount',
          allowFiltering : false,
          allowSorting : false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('قيمة القيد'))),
      GridColumn(
          columnName: '_currency',
          allowFiltering : false,
          allowSorting : false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('عملة القيد'))),
      GridColumn(
          columnName: '_rate',
          minimumWidth:50 ,
          width : 120,
          allowFiltering : false,
          allowSorting : false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('سعر العملة'))),
      GridColumn(
          columnName: '_ry',
          allowFiltering : false,
          allowSorting : false,
          minimumWidth:50 ,
          width : 120,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('مبلغ الحساب '))),

    ];
  }
}
