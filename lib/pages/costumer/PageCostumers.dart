import 'package:flutter/material.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/widgets/animated_card.dart';
import 'package:hussam_clinc/widgets/page_transition.dart';
import 'package:hussam_clinc/model/patients/PatientModel.dart';
import 'package:hussam_clinc/db/patients/dbpatient.dart';
import 'package:hussam_clinc/pages/costumer/PageAddCostumers.dart';
import 'package:hussam_clinc/pages/costumer/PageEditCostumers.dart';

import 'package:hussam_clinc/widgets/ClinicSwitcher.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/main.dart';

class PageCostumers extends StatefulWidget {
  final List<PatientModel> costumers;
  const PageCostumers(this.costumers, {super.key});

  @override
  State<PageCostumers> createState() => _PageCostumersState();
}

class _PageCostumersState extends State<PageCostumers> {
  late List<PatientModel> displayList;
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    displayList = _uniqueById(List.from(widget.costumers));
  }

  Future<void> _refreshData() async {
     await AllPatientList();
     if(mounted) {
       setState(() {
         displayList = _uniqueById(List.from(allPatient));
       });
     }
  }

  void _filterSearch(String query) {
    setState(() {
      displayList = _uniqueById(widget.costumers
          .where((patient) =>
              patient.name.toLowerCase().contains(query.toLowerCase()) ||
              patient.mobile.contains(query))
          .toList());
    });
  }

  List<PatientModel> _uniqueById(List<PatientModel> list) {
    final map = <int, PatientModel>{};
    for (final p in list) {
      map[p.id] = p;
    }
    return map.values.toList();
  }

  void _sortList() {
    setState(() {
      _isAscending = !_isAscending;
      displayList.sort((a, b) =>
          _isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    });
  }

  void _deletePatient(PatientModel patient, int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المريض "${patient.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DbPatient().deletePatient(patient.id);
      setState(() {
        displayList.removeAt(index);
        widget.costumers.removeWhere((p) => p.id == patient.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المريض بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المرضى'),
        actions: [
          // زر تبديل العيادة السريع
          ClinicSwitcher(
            showAsIcon: true,
            onClinicChanged: () async {
              await _refreshData();
            },
          ),
          IconButton(
            icon: Icon(_isAscending
                ? Icons.sort_by_alpha
                : Icons.sort_by_alpha_outlined),
            onPressed: _sortList,
            tooltip: 'ترتيب حسب الاسم',
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () {
              Navigator.of(context)
                  .push(PageTransition(child: const PageAddCostumers()));
            },
            tooltip: 'إضافة مريض جديد',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: displayList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final patient = displayList[index];
                      return AnimatedCard(
                        delay: Duration(milliseconds: index * 50),
                        child: _buildPatientCard(patient, index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearch,
        decoration: InputDecoration(
          hintText: 'البحث عن مريض...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                PageTransition(child: PageEditCostumers(patient)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      patient.name.isNotEmpty
                          ? patient.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم الملف: ${patient.fileNo}',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Mobile Number in the Middle
                  Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_android_rounded,
                            color: AppTheme.primaryColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          patient.mobile,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded,
                            color: Colors.blue, size: 28),
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransition(child: PageEditCostumers(patient)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red, size: 28),
                        onPressed: () => _deletePatient(patient, index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا يوجد مرضى مطابقين للبحث',
            style: TextStyle(color: Colors.grey[500], fontSize: 18),
          ),
        ],
      ),
    );
  }
}
