import 'package:flutter/material.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/db/dbemployee.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/model/Employment/EmployeeModel.dart';

class PageEditEmployee extends StatefulWidget {
  final EmployeeModel employee;
  const PageEditEmployee(this.employee, {super.key});

  @override
  State<PageEditEmployee> createState() => _PageEditEmployeeState();
}

class _PageEditEmployeeState extends State<PageEditEmployee> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _mobile;
  late String _jop;

  final List<String> _jobs = ['دكتور', 'سكرتير', 'فني', 'محاسب', 'آخر'];

  @override
  void initState() {
    super.initState();
    _name = widget.employee.name;
    _mobile = widget.employee.mobile;
    _jop = widget.employee.jop;
  }

  void _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await DbEmployee()
          .updateEmployee(widget.employee.id, _name, _mobile, _jop);
      await AllEmplyess();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث بيانات الموظف بنجاح')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات الموظف'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputCard(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: _inputDecoration('اسم الموظف', Icons.person),
                      validator: (val) => val == null || val.isEmpty
                          ? 'يرجى إدخال الاسم'
                          : null,
                      onSaved: (val) => _name = val!,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _mobile,
                      decoration:
                          _inputDecoration('رقم الجوال', Icons.phone_android),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.length < 10
                          ? 'يرجى إدخال رقم جوال صحيح'
                          : null,
                      onSaved: (val) => _mobile = val!,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _jobs.contains(_jop) ? _jop : 'آخر',
                      decoration:
                          _inputDecoration('الوظيفة', Icons.work_outline),
                      items: _jobs
                          .map((job) => DropdownMenuItem(
                                value: job,
                                child: Text(job),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _jop = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _updateEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.system_update_alt_rounded),
                    SizedBox(width: 10),
                    Text('تحديث البيانات',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
