import 'package:flutter/material.dart';
import 'package:hussam_clinc/model/Employment/EmployeeModel.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/widgets/animated_card.dart';
import 'package:hussam_clinc/db/dbemployee.dart';
import 'package:hussam_clinc/pages/employment/PageAddEmployee.dart';
import 'package:hussam_clinc/pages/employment/PageEditEmployee.dart';
import 'package:hussam_clinc/widgets/page_transition.dart';

class PageEmployees extends StatefulWidget {
  final List<EmployeeModel> employees;
  const PageEmployees(this.employees, {super.key});

  @override
  State<PageEmployees> createState() => _PageEmployeesState();
}

class _PageEmployeesState extends State<PageEmployees> {
  late List<EmployeeModel> displayList;
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    displayList = List.from(widget.employees);
  }

  void _filterSearch(String query) {
    setState(() {
      displayList = widget.employees
          .where((employee) =>
              employee.name.toLowerCase().contains(query.toLowerCase()) ||
              employee.mobile.contains(query) ||
              employee.jop.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _sortList() {
    setState(() {
      _isAscending = !_isAscending;
      displayList.sort((a, b) =>
          _isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    });
  }

  void _deleteEmployee(EmployeeModel employee, int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموظف "${employee.name}"؟'),
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
      await DbEmployee().deleteEmployee(employee.id);
      setState(() {
        displayList.removeAt(index);
        widget.employees.removeWhere((e) => e.id == employee.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الموظف بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الموظفين'),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            _buildHeaderActions(),
            Expanded(
              child: displayList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final employee = displayList[index];
                        return AnimatedCard(
                          delay: Duration(milliseconds: index * 50),
                          child: _buildEmployeeCard(employee, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'عدد الموظفين: ${displayList.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isAscending
                        ? Icons.sort_by_alpha
                        : Icons.sort_by_alpha_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: _sortList,
                  tooltip: 'ترتيب حسب الاسم',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_add_rounded,
                      color: AppTheme.primaryColor),
                  onPressed: () {
                    Navigator.of(context)
                        .push(PageTransition(child: const PageAddEmployee()))
                        .then((value) => setState(() {
                              displayList = List.from(widget.employees);
                            }));
                  },
                  tooltip: 'إضافة موظف جديد',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterSearch,
        decoration: InputDecoration(
          hintText: 'ابحث عن اسم الموظف، الهاتف، أو المسمى الوظيفي...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _filterSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Hero(
              tag: 'employee_avatar_${employee.id}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.8),
                      AppTheme.primaryColor.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    employee.name.isNotEmpty
                        ? employee.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  _buildInfoChip(
                    Icons.work_rounded,
                    employee.jop,
                    Colors.blue.withOpacity(0.1),
                    Colors.blue,
                  ),
                  _buildInfoChip(
                    Icons.phone_iphone_rounded,
                    employee.mobile,
                    Colors.green.withOpacity(0.1),
                    Colors.green,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 22),
                  color: AppTheme.secondaryColor,
                  onPressed: () {
                    Navigator.of(context)
                        .push(PageTransition(child: PageEditEmployee(employee)))
                        .then((value) => setState(() {
                              displayList = List.from(widget.employees);
                            }));
                  },
                  tooltip: 'تعديل البيانات',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 22, color: Colors.red[400]),
                  onPressed: () => _deleteEmployee(employee, index),
                  tooltip: 'حذف الموظف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String label, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: iconColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_off_rounded,
                size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على موظفين',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'حاول تغيير كلمات البحث',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
