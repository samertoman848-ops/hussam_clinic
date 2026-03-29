import 'package:flutter/material.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/main.dart';
import 'package:hussam_clinc/pages/accounting/invoices/expenseInvoicesReview.dart';
import 'package:hussam_clinc/pages/accounting/invoices/saleInvoicesReview.dart';
import 'package:hussam_clinc/pages/accounting/items/PageItems.dart';
import 'package:hussam_clinc/pages/reports/PageItemReport.dart';
import 'package:hussam_clinc/pages/accounting/journals/journalsReview.dart';
import 'package:hussam_clinc/pages/accounting/vouchers/receiptVoucher.dart';
import 'package:hussam_clinc/pages/accounting/vouchers/receiptVouchersReview.dart';
import 'package:hussam_clinc/pages/costumer/PageCostumers.dart';
import 'package:hussam_clinc/pages/employment/PageEmployees.dart';
import 'package:hussam_clinc/pages/settings/DbSettingsPage.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/widgets/animated_card.dart';
import 'package:hussam_clinc/widgets/page_transition.dart';
import 'package:hussam_clinc/widgets/ClinicSwitcher.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/services/AuthService.dart';
import 'package:hussam_clinc/services/ClinicService.dart';
import 'package:hussam_clinc/model/UserModel.dart';
import 'package:hussam_clinc/pages/auth/user_management_page.dart';
import 'package:hussam_clinc/pages/auth/login_page.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onClinicChanged;
  const AppDrawer({super.key, this.onClinicChanged});

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
                if (AuthService().currentUser?.hasPermission('patients') ??
                    true)
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
                if (AuthService().currentUser?.hasPermission('employees') ??
                    true)
                  AnimatedCard(
                    delay: const Duration(milliseconds: 200),
                    child: _buildMenuItem(
                      context,
                      title: 'الموظفين',
                      iconPath: "assets/icon/doctor.png",
                      onTap: () async {
                        await AllEmplyess();
                        if (context.mounted) {
                          Navigator.of(context).push(PageTransition(
                              child: PageEmployees(allEmployees)));
                        }
                      },
                    ),
                  ),
                if (AuthService().isAdmin)
                  AnimatedCard(
                    delay: const Duration(milliseconds: 300),
                    child: _buildMenuItem(
                      context,
                      title: 'إدارة المستخدمين',
                      icon: Icons.manage_accounts_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                            PageTransition(child: const UserManagementPage()));
                      },
                    ),
                  ),
                if (AuthService().currentUser?.hasPermission('settings') ??
                    true)
                  AnimatedCard(
                    delay: const Duration(milliseconds: 400),
                    child: _buildMenuItem(
                      context,
                      title: 'الإعدادات',
                      icon: Icons.settings,
                      onTap: () {
                        Navigator.of(context).push(
                            PageTransition(child: const DbSettingsPage()));
                      },
                    ),
                  ),
                if (!kIsWeb && AuthService().isAdmin)
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
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                            const SnackBar(
                                content: Text('بدأ رفع البيانات...')),
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
                // تبديل العيادات (إذا كانت هناك أكثر من عيادة واحدة)
                if (ClinicService().hasMultipleClinics)
                  AnimatedCard(
                    delay: const Duration(milliseconds: 350),
                    child: _buildMenuItem(
                      context,
                      title: 'تبديل العيادة',
                      icon: Icons.business,
                      onTap: () {
                        _showClinicSwitchDialog(context);
                      },
                    ),
                  ),
                const Divider(indent: 20, endIndent: 20),
                if (AuthService().currentUser?.hasPermission('accounting') ??
                    true)
                  AnimatedCard(
                    delay: const Duration(milliseconds: 500),
                    child: _buildExpansionTile(
                      context,
                      title: "المالية",
                      iconPath: "assets/accounting/accounting.png",
                      children: [
                        _buildSubMenuItem(
                          context,
                          title: 'الأصناف',
                          iconPath:
                              "assets/accounting/accounting.png", // Reusing icon for simplicity
                          onTap: () async {
                            Navigator.of(context)
                                .push(PageTransition(child: const PageItems()));
                          },
                        ),
                        _buildSubMenuItem(
                          context,
                          title: 'تقرير المخازن',
                          iconPath:
                              "assets/accounting/accounting.png", // Reusing icon
                          onTap: () async {
                            Navigator.of(context).push(
                                PageTransition(child: const PageItemReport()));
                          },
                        ),
                        _buildSubExpansionTile(
                          context,
                          title: "الفواتير",
                          iconPath: "assets/accounting/invoices.png",
                          children: [
                            _buildSubMenuItem(
                              context,
                              title: 'فاتورة المبيعات',
                              iconPath: "assets/accounting/expense_invoice.png",
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
                        if (AuthService()
                                .currentUser
                                ?.hasPermission('reports') ??
                            true)
                          _buildSubMenuItem(
                            context,
                            title: 'القيود',
                            iconPath: "assets/accounting/journal.png",
                            onTap: () async {
                              Journals();
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              Navigator.of(context).push(PageTransition(
                                  child: const JournalsReview()));
                            },
                          ),
                      ],
                    ),
                  ),
                _buildMenuItem(
                  context,
                  title: 'تسجيل الخروج',
                  icon: Icons.logout_rounded,
                  onTap: () {
                    AuthService().logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      PageTransition(child: const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    UserModel? user = AuthService().currentUser;
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
          Text(
            user?.username ?? 'عيادة حسام',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (user != null)
            Text(
              user.role == 'admin' ? 'مدير النظام' : 'مستخدم',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
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

  /// عرض حوار تبديل العيادات
  void _showClinicSwitchDialog(BuildContext context) {
    final clinicService = ClinicService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تبديل العيادة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ClinicSwitcher(
            showAsIcon: false,
            onClinicChanged: () {
              Navigator.pop(context);
              onClinicChanged?.call();
            },
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
