import 'package:flutter/material.dart';
import 'package:hussam_clinc/View_model/ViewModelJournals.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../../global_var/globals.dart';
import '../../../reports/reportSalesInvoicePDF.dart';

class JournalsPage extends StatefulWidget{
  const JournalsPage({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return JournalsPageState();
  }
}

var VMJournals = ViewModelJournals.impty();

class JournalsPageState extends State<JournalsPage>{
  @override
  void dispose (){
    super.dispose();
    VMJournals.saving=false;
  }
  @override
  void initState() {
    super.initState();
    if(VMJournals.saving==false) {
      VMJournals= ViewModelJournals.impty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Directionality(
        textDirection: TextDirection.rtl,
        child:Scaffold(
          appBar: AppBar(
            backgroundColor:const Color( 0xFF1D9D99),
            title: const Text(
              'مراجعة القيود',
              style: TextStyle(fontSize: 25,color: Colors.white),
            ),
            actions:BarActions(),
          ),
          body:
          Column(
            children: [
              const SizedBox(height: 20),
              firstRow(),
              const SizedBox(height: 25),
              secondRow(),
              const SizedBox(height: 25),
              thirdRow(),
              const SizedBox(height: 25),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: tabledata(),
                ),
              ),
              const SizedBox(height: 15),
              //FourRow(),
              const SizedBox(height: 70),
            ],
          ),
        ),
      );
  }
  /// Widgit
  List<Widget>BarActions() {
    return
      <Widget>[
        IconButton(
            iconSize:40,
            icon: const Icon(
                Icons.request_page_rounded,
                color:Colors.white
            ),
            onPressed: () {
              setState(() {
                reportSalesInvoicePDF InvoiceReport=reportSalesInvoicePDF();
                InvoiceReport.inti();
                InvoiceReport.stateManager= VMJournals.stateManager;
              });
            }),
        IconButton(
            iconSize:40,
            icon: const Icon(
                Icons.delete,
                color:Colors.white
            ),
            onPressed: () {
              setState(() {
                VMJournals.stateManager.removeCurrentRow();
              });
            }),
        IconButton(
            iconSize:40,
            icon:Icon(
                VMJournals.saving? Icons.edit:Icons.save,
                color:Colors.white
            ),
            onPressed: () {
              setState(() {
                /// the record is execces you must update record
                if(VMJournals.saving){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    action: SnackBarAction(
                      textColor:Colors.white,
                      backgroundColor:Colors.pinkAccent,
                      label: '  تعديل  فاتورة البيع ',
                      onPressed: () {
                        ///Todo Edite Invoices
                        //VMJournals.EditeInvoices(VMJournals.MaxInvoices);
                        VMJournals.saving=true;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor:Colors.blue,
                          content: Text(
                            ' تم تعديل  فاتورة البيع بنجاح ',
                            style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.white),
                          ),
                          duration: Duration(seconds: 4),
                        ));
                        AllPatientList();
                        copyExternalDB();
                      },
                    ),
                    content: const Column(
                      children: [
                        Text(
                          ' لم يتم تعديل فاتورة البيع ',
                          style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 5),
                  ));
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    action: SnackBarAction(
                      textColor:Colors.white,
                      backgroundColor:Colors.pinkAccent,
                      label: 'تأكيد  إضافة  فاتورة البيع ',
                      onPressed: () {
                        //VMJournals.AddNewInvoices();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor:Colors.green,
                          content: Text(
                            ' تم إضافة  فاتورة البيع بنجاح ',
                            style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.white),
                          ),
                          duration: Duration(seconds: 4),
                        ));
                        AllPatientList();
                        copyExternalDB();
                        setState(() {
                          VMJournals.saving=true;
                        });
                      },
                    ),
                    content: const Column(
                      children: [
                        Text(
                          ' لم يتم إضافة  فاتورة البيع ',
                          style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 5),
                  ));
                }//if
              });
            }),
      ];
  }

  Widget firstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Text( 'رقم القيد : ',style:  VMJournals.textStyleLabel, ),
            Text( VMJournals.Maxjournals,style:  VMJournals.textStyle, ),
          ],
        ),
        const SizedBox(width: 15),
        InkWell(
          onTap:() async {
            final date = await  VMJournals.pickDate(context);
            if (date == null) return;
            setState(() {
              VMJournals.dateDate = date;
            });
          },
          child:
          Row(
            children: [
              Text(
                'تاريخ القيد  :  ',
                style:  VMJournals.textStyleLabel,
              ),
              Text(
                '${ VMJournals.dateDate.year}/${ VMJournals.dateDate.month}/${ VMJournals.dateDate.day}',
                style:VMJournals.textStyle,
              ),
            ],
          ),
        ) ,
        const SizedBox(width: 15),
        InkWell(
          onTap:() async {
            VMJournals.Selectedtime = (await  VMJournals.picktime(context))!;
          },
          child:
          Row(
            children: [
              Text(
                'ساعة القيد  :  ',
                style: VMJournals.textStyleLabel,
              ),
              Text(
                '${VMJournals.Selectedtime.hour}:${VMJournals.Selectedtime.minute}',
                style:VMJournals.textStyle,
              ),
            ],
          ),
        ) ,
      ],
    );
  }
  Widget secondRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(flex: 1,),
        //const SizedBox(height: 10),
        const Spacer(flex: 1,),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              const SizedBox(width: 3),
              Text( 'عملة القيد : ',style: VMJournals.textStyleLabel, ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                width:80,
                decoration: BoxDecoration(
                  color:Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButton(
                  // Initial Value
                  value:VMJournals.currencySelect,
                  hint: const Text('العملة'),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_downward),
                  isExpanded:true,
                  selectedItemBuilder: (BuildContext context) { //<-- SEE HERE
                    return VMJournals.currnceyList
                        .map((String value) {
                      return Center(
                        child: Text(
                          VMJournals.currencySelect,
                          style: const TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList();
                  },
                  // Array list of items
                  items: VMJournals.currnceyList.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Center(
                        child: Text(items,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (Object? value) {
                    setState(() {
                      VMJournals.currencySelect=value.toString();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1,),
        // const SizedBox(height: 10),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              const SizedBox(width: 3),
              Text( ' سعر العملة : ',style: VMJournals.textStyleLabel, ),
              SizedBox(
                width: 100,
                height: 50,
                child: TextFormField(
                  textAlign : TextAlign.center,
                  initialValue: VMJournals.rate.toString(),
                  onSaved: (val) {
                    setState(() {
                      VMJournals.rate =  double.parse(val!);
                    });
                  },
                  onChanged: (val) {
                    setState(() {
                      VMJournals.rate =  double.parse(val)  ;
                    });
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                  // validate after each user interaction
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(fontSize: 16),
                  decoration: VMJournals.inputDecorationNoIcon("سعر العملة "),
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1,),
      ],
    );
  }
  Widget thirdRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0,right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(height: 8),
          //const Spacer(flex: 1,),
          Text( ' بيان القيد  : ',style: VMJournals.textStyleLabel, ),
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 50,
              child: TextFormField(
                textAlign : TextAlign.center,
                initialValue: VMJournals.description,
                onSaved: (val) {
                  setState(() {
                    VMJournals.description =  val!;
                  });
                },
                onChanged: (val) {
                  setState(() {
                    VMJournals.description =  val  ;
                  });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: const TextStyle(fontSize: 16),
                decoration: VMJournals.inputDecorationNoIcon("سعر العملة "),
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }
  PlutoGrid tabledata (){
    return PlutoGrid(
      columns: VMJournals.columns,
      rows: VMJournals.rows,
      mode:PlutoGridMode.popup,
      onLoaded: (event) {
        VMJournals.stateManager = event.stateManager;
        VMJournals.stateManager.setShowColumnFilter(false);
      },
      rowColorCallback:  (PlutoRowColorContext rowColorContext) {
        return rowColorContext.row.cells['id']?.value == '0'
            ? const Color(0xFFDABED1)
            : const Color(0xFFE2F6DF);
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        // PlutoRow currentRow=VMJournals.stateManager.currentRow!;
        // VMJournals.selecedIndexId(currentRow.cells['name']!.value.toString());
        // currentRow.cells['id_item']!.value=AccountingIndx_select_id;
        // ///Check if price
        // if(currentRow.cells['price']!.value==0){
        //   currentRow.cells['price']!.value= int.parse(AccountingIndexModel.selling_price);
        // }
        // ///Check if Qty is Statficed بضاعة
        // if(AccountingIndexModel.type=='بضاعة'){
        //   if(currentRow.cells['qty']!.value<=int.parse(AccountingIndexModel.balance)){
        //     currentRow.cells['total']!.value= currentRow.cells['price']!.value*currentRow.cells['qty']!.value;
        //   }else{
        //     SnackBar snackBar = const SnackBar(
        //       content: Text(" يجب أن تكون كمية البضاعة أقل من الكمية المصروفة"),
        //     );
        //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
        //     currentRow.cells['qty']!.value=int.parse(AccountingIndexModel.balance);
        //     currentRow.cells['total']!.value= currentRow.cells['price']!.value*currentRow.cells['qty']!.value;
        //   }
        // }else{
        //   currentRow.cells['total']!.value= currentRow.cells['price']!.value*currentRow.cells['qty']!.value;
        // }
        // VMJournals.amount=0;
        // VMJournals.stateManager.rows.forEach((e) {
        //   VMJournals.amount+= e.cells['total']!.value;
        // });
        // setState(() {
        //   // VMJournals.amount_all=VMJournals.amount-VMJournals.disscount;
        //   // VMJournals.remaining= VMJournals.amount_all-VMJournals.payment;
        // });
      },

      configuration: const PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          resizeMode : PlutoResizeMode.pushAndPull,
          autoSizeMode:PlutoAutoSizeMode.scale,

        ),
        localeText: PlutoGridLocaleText.arabic(),
        enableMoveHorizontalInEditing:true,
        style:PlutoGridStyleConfig(
          checkedColor:Color(0x11757575),
          evenRowColor: Colors.white12,
        ),
      ),
    );
  }
}





