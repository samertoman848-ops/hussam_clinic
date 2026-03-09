import 'package:flutter/material.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/main.dart';
import 'package:hussam_clinc/pages/accounting/invoices/SalesInvoices.dart';
import 'package:hussam_clinc/pages/accounting/invoices/SalesInvoicesOptions.dart';
import 'package:hussam_clinc/pages/accounting/invoices/expenseInvoices.dart';
import 'package:hussam_clinc/pages/accounting/invoices/expenseInvoicesReview.dart';
import 'package:hussam_clinc/pages/accounting/invoices/saleInvoicesReview.dart';
import 'package:hussam_clinc/pages/accounting/journals/journalsReview.dart';
import 'package:hussam_clinc/pages/accounting/vouchers/receiptVoucher.dart';
import 'package:hussam_clinc/pages/accounting/vouchers/receiptVouchersReview.dart';
import 'package:hussam_clinc/pages/costumer/PageCostumers.dart';
import 'package:hussam_clinc/pages/employment/PageEmployees.dart';
import 'package:hussam_clinc/pages/settings/DbSettingsPage.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/widgets/animated_card.dart';
import 'package:hussam_clinc/widgets/page_transition.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:flutter/foundation.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                AnimatedCard(
                  delay: const Duration(milliseconds: 100),
                  child: _buildMenuItem(
                    context,
                    title: 'المرضى',
                    iconPath: "assets/icon/patients.png",
                    onTap: () {
                      Navigator.of(context).push(
                          PageTransition(child: PageCostumers(allPatient)));
                    },
                  ),
                ),
                AnimatedCard(
                  delay: const Duration(milliseconds: 200),
                  child: _buildMenuItem(
                    context,
                    title: 'الموظفين',
                    iconPath: "assets/icon/doctor.png",
                    onTap: () async {
                      await AllEmplyess();
                      if (context.mounted) {
                        Navigator.of(context).push(
                            PageTransition(child: PageEmployees(allEmployees)));
                      }
                    },
                  ),
                ),
                AnimatedCard(
                  delay: const Duration(milliseconds: 300),
                  child: _buildMenuItem(
                    context,
                    title: 'الموردين',
                    iconPath: "assets/icon/supliers.png",
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('قريباً: صفحة الموردين'),
                          backgroundColor: AppTheme.secondaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
                AnimatedCard(
                  delay: const Duration(milliseconds: 400),
                  child: _buildMenuItem(
                    context,
                    title: 'الإعدادات',
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.of(context)
                          .push(PageTransition(child: const DbSettingsPage()));
                    },
                  ),
                ),
                if (!kIsWeb)
                  AnimatedCard(
                    delay: const Duration(milliseconds: 450),
                    child: _buildMenuItem(
                      context,
                      title: 'مزامنة السحابة',
                      icon: Icons.cloud_upload,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('مزامنة شاملة'),
                            content: const Text(
                                'هل تريد رفع جميع البيانات المحلية إلى السحابة؟ قد يستغرق هذا بعض الوقت.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('إلغاء')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('رفع الآن')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('بدأ رفع البيانات...')),
                          );
                          try {
                            await FirebaseSyncService.instance
                                .uploadAllDataToFirebase();
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('اكتملت المزامنة بنجاح!')),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('خطأ أثناء المزامنة: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                const Divider(indent: 20, endIndent: 20),
                AnimatedCard(
                  delay: const Duration(milliseconds: 500),
                  child: _buildExpansionTile(
                    context,
                    title: "المالية",
                    iconPath: "assets/accounting/accounting.png",
                    children: [
                      _buildSubExpansionTile(
                        context,
                        title: "الفواتير",
                        iconPath: "assets/accounting/invoices.png",
                        children: [
                          _buildSubMenuItem(
                            context,
                            title: 'فاتورة المبيعات',
                            iconPath: "assets/accounting/expense_invoice.png",
                            onTap: () {
                              Navigator.of(context).push(PageTransition(
                                  child: const SalesInvoicesOptions()));
                            },
                          ),
                          _buildSubMenuItem(
                            context,
                            title: ' مراجعة فواتير المبيعات',
                            iconPath:
                                "assets/accounting/expense_invoice_reviwe.png",
                            onTap: () async {
                              AllInvioces();
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              Navigator.of(context).push(PageTransition(
                                  child: const SaleInvoicesReview()));
                            },
                          ),
                          _buildSubMenuItem(
                            context,
                            title: 'فاتورة مشتريات',
                            iconPath: "assets/accounting/sales_invoice.png",
                            onTap: () async {
                              AllEmplyess();
                              VMGlobal.MaxNoS();
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              Navigator.of(context).push(PageTransition(
                                  child: const ExpenseInvoices()));
                            },
                          ),
                          _buildSubMenuItem(
                            context,
                            title: ' مراجعة فواتير المشتريات',
                            iconPath:
                                "assets/accounting/sales_invoice_reviwe.png",
                            onTap: () async {
                              ExpenseInvioces();
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              Navigator.of(context).push(PageTransition(
                                  child: const ExpenseInvoicesReview()));
                            },
                          ),
                        ],
                      ),
                      _buildSubExpansionTile(
                        context,
                        title: "الإيصال",
                        iconPath: "assets/accounting/vouchers.png",
                        children: [
                          _buildSubMenuItem(
                            context,
                            title: 'إيصال قبض',
                            iconPath: "assets/accounting/reciept_voucher.png",
                            onTap: () async {
                              Navigator.of(context).push(PageTransition(
                                  child:
                                      const ReceiptVoucherPage(type: 'قبض')));
                            },
                          ),
                          _buildSubMenuItem(
                            context,
                            title: ' مراجعة إيصال القبض ',
                            iconPath:
                                "assets/accounting/reciept_voucher_reviwe.png",
                            onTap: () async {
                              Navigator.of(context).push(PageTransition(
                                  child: const ReceiptVouchersReview(
                                      type: 'قبض')));
                            },
                          ),
                          _buildSubMenuItem(
                            context,
                            title: 'إيصال صرف',
                            iconPath: "assets/accounting/payment_voucher.png",
                            onTap: () async {
                              Navigator.of(context).push(PageTransition(
                                  child:
                                      const ReceiptVoucherPage(type: 'صرف')));
                            },
                          ),
                          _buildSubMenuItem(
                            context,
                            title: ' مراجعة إيصال الصرف ',
                            iconPath:
                                "assets/accounting/payment_voucher_reviwe.png",
                            onTap: () async {
                              Navigator.of(context).push(PageTransition(
                                  child: const ReceiptVouchersReview(
                                      type: 'صرف')));
                            },
                          ),
                        ],
                      ),
                      _buildSubMenuItem(
                        context,
                        title: 'القيود',
                        iconPath: "assets/accounting/journal.png",
                        onTap: () async {
                          Journals();
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          Navigator.of(context).push(
                              PageTransition(child: const JournalsReview()));
                        },
                      ),
                      _buildSubMenuItem(
                        context,
                        title: 'حركة الحساب',
                        iconPath: "assets/accounting/calculation.png",
                        onTap: () {},
                      ),
                      _buildSubMenuItem(
                        context,
                        title: ' شجرة الحسابات',
                        iconPath: "assets/accounting/tree.png",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'logo',
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 60,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'عيادة حسام',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required String title,
      String? iconPath,
      IconData? icon,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: iconPath != null
            ? Image.asset(iconPath, width: 30, height: 30)
            : Icon(icon, size: 30, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: onTap,
        hoverColor: AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context,
      {required String title,
      required String iconPath,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: ListTile(
        leading: Image.asset(iconPath, width: 25, height: 25),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context,
      {required String title,
      required String iconPath,
      required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ExpansionTile(
        leading: Image.asset(iconPath, width: 30, height: 30),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        iconColor: AppTheme.primaryColor,
        collapsedIconColor: Colors.grey,
        shape: const Border(),
        children: children,
      ),
    );
  }

  Widget _buildSubExpansionTile(BuildContext context,
      {required String title,
      required String iconPath,
      required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: ExpansionTile(
        leading: Image.asset(iconPath, width: 25, height: 25),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        shape: const Border(),
        children: children,
      ),
    );
  }
}
