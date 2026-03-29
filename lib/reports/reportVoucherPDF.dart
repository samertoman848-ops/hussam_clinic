import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:hussam_clinc/model/accounting/VoucherModel.dart';
import '../global_var/globals.dart';

class reportVoucherPDF {
  final VoucherModel voucher;
  reportVoucherPDF(this.voucher);

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
    
    savePDFFile(bytes, 'سند_${voucher.className}_رقم_${voucher.id.toString().padLeft(6, '0')}.pdf');
  }

  void createPdfDocument(pw.Document pdf, pw.Font fontPage,
      pw.Font fontTableDetail, pw.MemoryImage image, pw.Font fontTableHeader) {
    pdf.addPage(pw.MultiPage(
        header: (pw.Context context) => Header(fontPage, image),
        theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: fontTableDetail)),
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Header(text: ''),
            pw.SizedBox(height: 10),
            _buildVoucherDetails(fontPage),
            pw.Spacer(),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('توقيع المحاسب', style: pw.TextStyle(font: fontPage, fontSize: 14)),
                pw.Text('توقيع المستلم', style: pw.TextStyle(font: fontPage, fontSize: 14)),
              ],
            ),
          ];
        }));
  }

  pw.Widget _buildVoucherDetails(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
      child: pw.Column(
        children: [
          _row(font, 'رقم السند:', voucher.id.toString().padLeft(6, '0')),
          _row(font, 'التاريخ:', voucher.date),
          _row(font, 'يصرف لـ / يستلم من:', voucher.dealer),
          _row(font, 'مبلغ وقدره:', '${voucher.payment} ${voucher.currency}'),
          _row(font, 'وذلك عن:', voucher.discription),
        ],
      ),
    );
  }

  pw.Widget _row(pw.Font font, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: font))),
        ],
      ),
    );
  }

  pw.Table Header(pw.Font fontPage, pw.MemoryImage image) {
    return pw.Table(
      children: [
        pw.TableRow(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Dental Clinic', style: pw.TextStyle(font: fontPage, fontSize: 14, color: PdfColors.blueAccent)),
                pw.Text('Dr.Hussam M. Aydi', style: pw.TextStyle(font: fontPage, fontSize: 14, color: PdfColors.blueAccent)),
              ],
            ),
            pw.Column(
              children: [
                pw.Text('سند ${voucher.className}', style: pw.TextStyle(font: fontPage, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Image(image, height: 40, width: 40),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('عيادة طب الأسنان', style: pw.TextStyle(font: fontPage, fontSize: 14, color: PdfColors.blueAccent)),
                pw.Text('د.حسام محمد العايدي', style: pw.TextStyle(font: fontPage, fontSize: 14, color: PdfColors.blueAccent)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
