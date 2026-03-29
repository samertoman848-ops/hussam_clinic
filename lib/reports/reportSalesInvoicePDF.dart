import 'package:flutter/services.dart';
import 'package:hussam_clinc/pages/accounting/invoices/SalesInvoices.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesModel.dart' as accModel;
import 'package:hussam_clinc/model/accounting/invoices/InvoicesDetailModel.dart' as accDetail;
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../global_var/globals.dart';

class reportSalesInvoicePDF {
  PlutoGridStateManager? stateManager;
  accModel.InvoicesModel? invoice;

  reportSalesInvoicePDF();
  reportSalesInvoicePDF.fromInvoice(this.invoice);

  Future<void> inti() async {
    var fontTableDetail1 = await rootBundle.load("assets/fonts/ArbFONTS-Amiri.ttf");
    final fontTableDetail = pw.Font.ttf(fontTableDetail1);
    var fontTableHeader1 = await rootBundle.load("assets/fonts/ArbFONTS-Amiri-Bold.ttf");
    final pw.Font fontTableHeader = pw.Font.ttf(fontTableHeader1);
    var fontPage1 = await rootBundle.load("assets/fonts/ArbFONTS-Amiri-Bold.ttf");
    final pw.Font fontPage = pw.Font.ttf(fontPage1);
    
    final pdf = pw.Document();
    final image = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List());
        
    createPdfDocument(pdf, fontPage, fontTableDetail, image, fontTableHeader);
    List<int> bytes = await pdf.save();
    
    String invNo = invoice != null ? invoice!.id.toString() : VMSalesInvoice.MaxInvoices;
    savePDFFile(bytes, ' فاتورة بيع رقم_${invNo.padLeft(6, '0')}.pdf');
  }

  void createPdfDocument(pw.Document pdf, pw.Font fontPage,
      pw.Font fontTableDetail, pw.MemoryImage image, pw.Font fontTableHeader) {
    pdf.addPage(pw.MultiPage(
        header: (pw.Context context) => Header(fontPage, image),
        theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: fontTableDetail)),
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(text: ''),
            FistData(fontPage),
            pw.Divider(color: PdfColors.white, thickness: 1, height: 2),
            buildTableExportItems(fontPage),
            pw.Header(text: ''),
            FinalData(fontPage),
            pw.Divider(color: PdfColors.white, thickness: 1, height: 2),
          ];
        }));
  }

  pw.Table Header(pw.Font fontPage, pw.MemoryImage image) {
    return pw.Table(
      children: [
        pw.TableRow(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Dental Clinic', style: pw.TextStyle(font: fontPage, fontSize: 16, color: PdfColors.deepOrange400)),
                pw.Text('Dr.Hussam M. Aydi', style: pw.TextStyle(font: fontPage, fontSize: 16, color: PdfColors.deepOrange400)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Center(child: pw.Text('فاتورة بيع', style: pwTableHeadingTextStyle(fontPage, 14))),
                pw.Image(image, height: 50, width: 50),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('عيادة طب الفم والأسنان', style: pw.TextStyle(font: fontPage, fontSize: 16, color: PdfColors.deepOrange400)),
                pw.Text('د.حسام محمد العايدي', style: pw.TextStyle(font: fontPage, fontSize: 16, color: PdfColors.deepOrange400)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Table FistData(pw.Font fontPage) {
    String id = invoice?.id.toString().padLeft(6, '0') ?? VMSalesInvoice.MaxInvoices.padLeft(6, '0');
    String currency = invoice?.currency ?? VMSalesInvoice.currencySelect;
    String accId = invoice?.account_no ?? VMSalesInvoice.AccountingPerson_select_id;
    String accName = invoice?.account_name ?? VMSalesInvoice.AccountingPerson_select_name;
    String date = invoice?.date ?? '${VMSalesInvoice.dateDate.day}/${VMSalesInvoice.dateDate.month}/${VMSalesInvoice.dateDate.year}';
    String time = invoice?.time ?? '${VMSalesInvoice.Selectedtime.hour}:${VMSalesInvoice.Selectedtime.minute}';

    return pw.Table(children: [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              pw.Text(' رقم الفاتورة : $id', style: pwTableHeadingTextStyle(fontPage, 14)),
              pw.Text(" عملة الفاتورة :  $currency", style: pwTableHeadingTextStyle(fontPage, 14)),
            ]),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              pw.Text(" رقم المريض : $accId", style: pwTableHeadingTextStyle(fontPage, 14)),
              pw.Text(' الساعة: $time', style: pwTableHeadingTextStyle(fontPage, 14)),
            ]),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              pw.Text(" اسم المريض : $accName", style: pwTableHeadingTextStyle(fontPage, 14)),
              pw.Text(' التاريخ: $date', style: pwTableHeadingTextStyle(fontPage, 14)),
            ]),
          ),
        ],
      ),
    ]);
  }

  pw.Table FinalData(pw.Font fontPage) {
    String total = invoice?.amount_all ?? VMSalesInvoice.amount_all.toString();
    String currency = invoice?.currency ?? VMSalesInvoice.currencySelect;
    
    return pw.Table(children: [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('    الفاتورة الإجمالية : $total $currency ', style: pwTableHeadingTextStyle(fontPage, 14, color: const PdfColor(1, 0, 0, .8))),
            ]),
          ),
          remaningMony(fontPage),
          payedMony(fontPage),
        ],
      ),
    ]);
  }

  pw.Padding remaningMony(pw.Font fontPage) {
    double rem = double.tryParse(invoice?.remaining ?? VMSalesInvoice.remaining.toString()) ?? 0;
    String disc = invoice?.disscount ?? VMSalesInvoice.disscount.toString();
    String curr = invoice?.currency ?? VMSalesInvoice.currencySelect;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.Text('قيمة الخصم : $disc $curr ', style: pwTableHeadingTextStyle(fontPage, 12)),
        if (rem > 0)
          pw.Text('المبلغ المتبقي : $rem $curr ', style: pwTableHeadingTextStyle(fontPage, 12, color: PdfColors.red)),
      ]),
    );
  }

  pw.Padding payedMony(pw.Font fontPage) {
    String amt = invoice?.amount ?? VMSalesInvoice.amount.toString();
    String pay = invoice?.payment ?? VMSalesInvoice.payment.toString();
    String curr = invoice?.currency ?? VMSalesInvoice.currencySelect;
    String pCurr = invoice?.payment_currency ?? VMSalesInvoice.payment_currency;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        pw.Text('مبلغ الفاتورة : $amt $curr ', style: pwTableHeadingTextStyle(fontPage, 12)),
        if (double.parse(pay) > 0)
          pw.Text('المدفوع نقداً : $pay $pCurr ', style: pwTableHeadingTextStyle(fontPage, 12, color: PdfColors.blue)),
      ]),
    );
  }

  pw.Table buildTableExportItems(pw.Font fontTableDetail) {
    List<dynamic> items = [];
    if (stateManager != null) {
      items = stateManager!.rows;
    } else if (invoice != null) {
      items = invoice!.details;
    }

    return pw.Table(
      border: tableBorder(),
      children: List.generate(items.length + 1, (index) {
        if (index == 0) {
          return pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColor(.8, .8, .8, .8)),
            children: [
              pw.Center(child: pw.Text('الإجمالي', style: TableTextStyle(fontTableDetail))),
              pw.Center(child: pw.Text('السعر', style: TableTextStyle(fontTableDetail))),
              pw.Center(child: pw.Text('الكمية', style: TableTextStyle(fontTableDetail))),
              pw.Center(child: pw.Text('اسم الصنف', style: TableTextStyle(fontTableDetail))),
              pw.Center(child: pw.Text('الرقم', style: TableTextStyle(fontTableDetail))),
            ],
          );
        }
        
        var i = index - 1;
        String id, name, qty, price, total;
        
        if (stateManager != null) {
          var row = stateManager!.rows[i];
          id = row.cells['id']?.value.toString() ?? '';
          name = row.cells['name']?.value.toString() ?? '';
          qty = row.cells['qty']?.value.toString() ?? '';
          price = row.cells['price']?.value.toString() ?? '';
          total = row.cells['total']?.value.toString() ?? '';
        } else {
          var det = items[i] as accDetail.InvoicesDetailModel;
          id = (i+1).toString();
          name = det.item_name;
          qty = det.unit_qty;
          price = det.unit_price;
          total = det.net_price;
        }

        return pw.TableRow(
          children: [
            pw.Center(child: pw.Text(total, style: TableTextStyle(fontTableDetail))),
            pw.Center(child: pw.Text(price, style: TableTextStyle(fontTableDetail))),
            pw.Center(child: pw.Text(qty, style: TableTextStyle(fontTableDetail))),
            pw.Center(child: pw.Text(name, style: TableTextStyle(fontTableDetail))),
            pw.Center(child: pw.Text(id, style: TableTextStyle(fontTableDetail))),
          ],
        );
      }),
    );
  }

  pw.TableBorder tableBorder() => pw.TableBorder.all(width: 1, color: PdfColors.black);
  pw.TextStyle TableTextStyle(pw.Font font) => pw.TextStyle(fontSize: 12, font: font);
  pw.TextStyle pwTableHeadingTextStyle(pw.Font font, double size, {PdfColor? color}) =>
      pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: size, color: color ?? PdfColors.black);
}
