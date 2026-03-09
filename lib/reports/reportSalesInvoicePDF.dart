import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/pages/accounting/invoices/SalesInvoices.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' as material;
import 'package:pdf/pdf.dart';
import '../global_var/globals.dart';

class reportSalesInvoicePDF {
  late PlutoGridStateManager stateManager;
  reportSalesInvoicePDF();

  Future<void> inti() async {
    var fontTableDetail1 =
        await rootBundle.load("assets/fonts/ArbFONTS-Amiri.ttf");
    final fontTableDetail = pw.Font.ttf(fontTableDetail1);
    var fontTableHeader1 =
        await rootBundle.load("assets/fonts/ArbFONTS-Amiri-Bold.ttf");
    final pw.Font fontTableHeader = pw.Font.ttf(fontTableHeader1);
    var fontPage1 =
        await rootBundle.load("assets/fonts/ArbFONTS-Amiri-Bold.ttf");
    final pw.Font fontPage = pw.Font.ttf(fontPage1);
    final pdf = pw.Document();
    final image = material.MemoryImage(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
        scale: .3);
    createPdfDocument(pdf, fontPage, fontTableDetail, image, fontTableHeader);
    List<int> bytes = await pdf.save();
    savePDFFile(bytes, ' فاتورة بيع رقم_${VMSalesInvoice.MaxInvoices}.pdf');
  }

  void createPdfDocument(pw.Document pdf, pw.Font fontPage,
      pw.Font fontTableDetail, MemoryImage image, pw.Font fontTableHeader) {
    pdf.addPage(pw.MultiPage(
        header: (pw.Context context) {
          return Header(fontPage, image);
        },
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(font: fontTableDetail),
        ),
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.only(
            left: 20, right: 20, top: 5, bottom: 5), // This is the page margin
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              text: '',
            ),
            // Details
            FistData(fontPage),
            pw.Divider(color: PdfColors.white, thickness: 1, height: 2),
            // Items Table
            buildTableExportItems(fontPage),
            pw.Header(text: ''),
            // Divider
            //pw.Divider(color: PdfColors.white, thickness: 1,height:2 ),
            FinalData(fontPage),
            pw.Divider(color: PdfColors.white, thickness: 1, height: 2),
            // pw.Paragraph(text: "التوقيع",style:  pwTableHeadingTextStyle(fontTableHeader,20)),
          ];
        }));
  }

  pw.Table Header(pw.Font fontPage, MemoryImage image) {
    return pw.Table(
      children: [
        pw.TableRow(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Dental Clinic',
                  style: pw.TextStyle(
                      font: fontPage,
                      fontSize: 16,
                      color: PdfColors.deepOrange400),
                ),
                pw.Text(
                  'Dr.Hussam M. Aydi',
                  style: pw.TextStyle(
                      font: fontPage,
                      fontSize: 16,
                      color: PdfColors.deepOrange400),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              verticalDirection: pw.VerticalDirection.up,
              children: [
                pw.Center(
                  child: pw.Text('فاتورة بيع',
                      style: pwTableHeadingTextStyle(fontPage, 14)),
                ),
                pw.Image(pw.MemoryImage(image.bytes), height: 50, width: 50),
              ],
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'عيادة طب الفم والأسنان',
                  style: pw.TextStyle(
                      font: fontPage,
                      fontSize: 16,
                      color: PdfColors.deepOrange400),
                ),
                pw.Text(
                  'د.حسام محمد العايدي',
                  style: pw.TextStyle(
                      font: fontPage,
                      fontSize: 16,
                      color: PdfColors.deepOrange400),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Table FistData(pw.Font fontPage) {
    return pw.Table(// This is the starting widget for the table
        children: [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  ' رقم الفاتورة : ${VMSalesInvoice.MaxInvoices}',
                  style: pwTableHeadingTextStyle(fontPage, 14),
                ),
                pw.Text(" عملة الفاتورة :  ${VMSalesInvoice.currencySelect}",
                    style: pwTableHeadingTextStyle(fontPage, 14)),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                      " رقم المريض : ${VMSalesInvoice.AccountingPerson_select_id}",
                      style: pwTableHeadingTextStyle(fontPage, 14)),
                  pw.Text(
                    ' الساعة: ${VMSalesInvoice.Selectedtime.hour}:${VMSalesInvoice.Selectedtime.minute}',
                    style: pwTableHeadingTextStyle(fontPage, 14),
                  ),
                ]),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                      " اسم المريض : ${VMSalesInvoice.AccountingPerson_select_name}",
                      style: pwTableHeadingTextStyle(fontPage, 14)),
                  pw.Text(
                    ' التاريخ: ${VMSalesInvoice.dateDate.day}/${VMSalesInvoice.dateDate.month}/${VMSalesInvoice.dateDate.year}',
                    style: pwTableHeadingTextStyle(fontPage, 14),
                  ),
                ]),
          ),
        ],
      ),
    ]);
  }

  pw.Table FinalData(pw.Font fontPage) {
    return pw.Table(// This is the starting widget for the table
        children: [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(
                  '    الفاتورة الإجمالية : ${VMSalesInvoice.amount_all} ${VMSalesInvoice.currencySelect} ',
                  style: pwTableHeadingTextStyle(fontPage, 14,
                      color: const PdfColor(1, 0, 0, .8)),
                ),
              ],
            ),
          ),
          remaningMony(fontPage),
          payedMony(fontPage),
        ],
      ),
    ]);
  }

  pw.Padding remaningMony(pw.Font fontPage) {
    if (VMSalesInvoice.remaining > 0) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child:
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text(
            'قيمة الخصم : ${VMSalesInvoice.disscount} ${VMSalesInvoice.currencySelect} ',
            style: pwTableHeadingTextStyle(fontPage, 12),
          ),
          pw.Text(
            'المبلغ المتبقي : ${VMSalesInvoice.remaining} ${VMSalesInvoice.currencySelect} ',
            style: pwTableHeadingTextStyle(fontPage, 12, color: PdfColors.red),
          ),
        ]),
      );
    } else {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child:
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text(
            '   قيمة الخصم : ${VMSalesInvoice.disscount} ${VMSalesInvoice.currencySelect} ',
            style: pwTableHeadingTextStyle(fontPage, 14),
          ),
        ]),
      );
    }
  }

  pw.Padding payedMony(pw.Font fontPage) {
    List<pw.Widget> children = [];
    children.add(pw.Text(
        'مبلغ الفاتورة : ${VMSalesInvoice.amount} ${VMSalesInvoice.currencySelect} ',
        style: pwTableHeadingTextStyle(fontPage, 12)));

    if (VMSalesInvoice.payment > 0) {
      children.add(pw.Text(
          'المدفوع نقداً : ${VMSalesInvoice.payment} ${VMSalesInvoice.payment_currency} ',
          style: pwTableHeadingTextStyle(fontPage, 12, color: PdfColors.blue)));
    }

    if (VMSalesInvoice.payment_app > 0) {
      children.add(pw.Text(
          'المدفوع تطبيق : ${VMSalesInvoice.payment_app} ${VMSalesInvoice.payment_currency} ',
          style: pwTableHeadingTextStyle(fontPage, 12, color: PdfColors.blue)));
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: children,
      ),
    );
  }

  pw.TableBorder tableBorder() {
    return const pw.TableBorder(
        right: pw.BorderSide(
            width: 2,
            color: PdfColor(0, 0, 0, .8),
            style: pw.BorderStyle.solid),
        left: pw.BorderSide(
            width: 2,
            color: PdfColor(0, 0, 0, .8),
            style: pw.BorderStyle.solid),
        top: pw.BorderSide(
            width: 2,
            color: PdfColor(0, 0, 0, .8),
            style: pw.BorderStyle.solid),
        bottom: pw.BorderSide(
            width: 2,
            color: PdfColor(0, 0, 0, .8),
            style: pw.BorderStyle.solid),
        horizontalInside: pw.BorderSide(
            width: 1,
            color: PdfColor(0, 0, 0, .8),
            style: pw.BorderStyle.solid),
        verticalInside: pw.BorderSide(
            width: 1,
            color: PdfColor(0, 0, 0, .8),
            style: pw.BorderStyle.solid));
  }

  pw.Table buildTableExportItems(pw.Font fontTableDetail) {
    int noRowsTable = stateManager.rows.length;
    return pw.Table(
      border: tableBorder(),
      children: List.generate(
        noRowsTable + 1,
        (index) {
          var i = index - 1;
          if (i < 0) {
            return pw.TableRow(
              decoration: const pw.BoxDecoration(
                  shape: pw.BoxShape.rectangle,
                  color: PdfColor(.8, .8, .8, .8)),
              children: [
                pw.Column(
                  children: [
                    pw.Text('الإجمالي', style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('السعر', style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('الكمية', style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('اسم الصنف',
                        style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('الرقم', style: TableTextStyle(fontTableDetail)),
                  ],
                ),
              ],
            );
          } else if (i < noRowsTable && i >= 0) {
            return pw.TableRow(
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                        stateManager.rows[i].cells['total']!.value.toString(),
                        style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                        stateManager.rows[i].cells['price']!.value.toString(),
                        style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(stateManager.rows[i].cells['qty']!.value.toString(),
                        style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                        stateManager.rows[i].cells['name']!.value.toString(),
                        style: TableTextStyle(fontTableDetail)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(stateManager.rows[i].cells['id']!.value.toString(),
                        style: TableTextStyle(fontTableDetail)),
                  ],
                ),
              ],
            );
          }
          return pw.TableRow(children: [
            pw.Column(
              children: [
                pw.Text(index.toString(),
                    style: TableTextStyle(fontTableDetail)),
              ],
            ),
          ]);
        },
      ),
    );
  }

  pw.TextStyle TableTextStyle(pw.Font font) {
    return pw.TextStyle(
      fontSize: 14,
      font: font,
    );
  }

  pw.TextStyle pwTableHeadingTextStyle(pw.Font font, double Fontsize,
      {PdfColor? color}) {
    color != null ? const PdfColor(0, 0, 0, .8) : color;
    return pw.TextStyle(
        font: font,
        fontWeight: pw.FontWeight.bold,
        fontSize: Fontsize,
        color: color);
  }

  pw.Padding paddedTextCell(String textContent) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child:
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(textContent, textAlign: pw.TextAlign.left),
      ]),
    );
  }

  pw.Padding paddedHeadingTextCell(String textContent) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(children: [
        pw.Text(
          textContent,
          // style: pwTableHeadingTextStyle(tamilFont),
        ),
      ]),
    );
  }
}
