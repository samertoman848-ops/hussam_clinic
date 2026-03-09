import 'package:flutter/material.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/main.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/widgets/page_transition.dart';
import 'package:hussam_clinc/View_model/ViewModelSalesInvoices.dart';
import 'package:hussam_clinc/db/patients/dbpatient.dart';
import 'package:hussam_clinc/model/accounting/AccoutingTreeModel.dart';
import 'SalesInvoices.dart';
import 'saleInvoicesReview.dart';

class SalesInvoicesOptions extends StatelessWidget {
  const SalesInvoicesOptions({super.key});

  // دالة لتحميل أسماء المرضى من جدول patients مباشرة
  Future<void> _loadAllPatients() async {
    try {
      DbPatient dbPatient = DbPatient();
      final patients = await dbPatient.allPatients();

      // إضافة المرضى إلى قائمة العملاء
      allAccountingCoustmers.clear();
      allAccountingCoustmers_s.clear();

      for (var patient in patients) {
        AccoutingTreeModel tree = AccoutingTreeModel.Valueed(
          patient.id,
          patient.name,
          patient.id.toString(),
          '5200',
          patient.id.toString(),
        );
        allAccountingCoustmers.add(tree);
        if (patient.name.isNotEmpty) {
          allAccountingCoustmers_s.add(patient.name);
        }
      }

      print(
          'تم تحميل ${allAccountingCoustmers_s.length} اسم مريض من جدول patients');
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text(
            'فواتير المبيعات',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // إنشاء فاتورة جديدة
              _buildOptionCard(
                context,
                title: 'إنشاء فاتورة جديدة',
                subtitle: 'قم بإنشاء فاتورة مبيعات جديدة',
                icon: Icons.add_circle_outline,
                color: const Color(0xFF4CAF50),
                onTap: () async {
                  await AllEmplyess();
                  await AllPaitentsTreeList();
                  // تحميل إضافي من جدول patients مباشرة
                  await _loadAllPatients();
                  VMGlobal.MaxNoS();
                  // إعادة تعيين الفاتورة لفاتورة جديدة فارغة
                  VMSalesInvoice = ViewModelSalesInvoices.impty();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      PageTransition(child: const SalesInvoices()),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              // عرض الفواتير الموجودة
              _buildOptionCard(
                context,
                title: 'عرض الفواتير الموجودة',
                subtitle: 'اعرض ومراجعة فواتير المبيعات',
                icon: Icons.list_alt_rounded,
                color: const Color(0xFF2196F3),
                onTap: () async {
                  AllInvioces();
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (context.mounted) {
                    Navigator.of(context).push(
                      PageTransition(child: const SaleInvoicesReview()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
