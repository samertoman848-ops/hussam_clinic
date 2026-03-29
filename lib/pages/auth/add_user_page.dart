import 'package:flutter/material.dart';
import '../../model/UserModel.dart';
import '../../services/AuthService.dart';
import '../../theme/app_theme.dart';

class AddUserPage extends StatefulWidget {
  final UserModel? user;
  const AddUserPage({super.key, this.user});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late String _role;
  late List<String> _selectedPermissions;

  final List<Map<String, dynamic>> _allPermissions = [
    {
      'id': 'patients',
      'label': 'إدارة المرضى',
      'desc': 'عرض، إضافة، وحذف ملفات المرضى وتاريخ العلاج.',
      'icon': Icons.people_alt_rounded,
    },
    {
      'id': 'accounting',
      'label': 'المحاسبة والمالية',
      'desc': 'الوصول للفواتير، المشتريات، وسندات القبض والصرف.',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'reports',
      'label': 'التقارير والقيود',
      'desc': 'مراجعة التقارير المالية والقيود اليومية والميزانية.',
      'icon': Icons.bar_chart_rounded,
    },
    {
      'id': 'employees',
      'label': 'إدارة الموظفين',
      'desc': 'إدارة بيانات الكادر الطبي والموظفين والرواتب.',
      'icon': Icons.badge_rounded,
    },
    {
      'id': 'settings',
      'label': 'الإعدادات العامة',
      'desc': 'تغيير إعدادات العيادة، النسخ الاحتياطي وإدارة المستخدمين.',
      'icon': Icons.settings_suggest_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _passwordController = TextEditingController(text: widget.user?.password ?? '');
    _role = widget.user?.role ?? 'user';
    _selectedPermissions = List.from(widget.user?.permissions ?? []);
    
    // Legacy support: if they had 'all', select all IDs
    if (_selectedPermissions.contains('all')) {
      _selectedPermissions = _allPermissions.map((e) => e['id'] as String).toList();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final newUser = UserModel(
      id: widget.user?.id,
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      role: _role,
      permissions: _role == 'admin' ? ['all'] : _selectedPermissions,
    );

    try {
      if (widget.user == null) {
        await AuthService().addUser(newUser);
      } else {
        await AuthService().updateUser(newUser);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user == null ? 'تم إضافة المستخدم بنجاح' : 'تم تحديث البيانات بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.user != null;
    bool isAdmin = _role == 'admin';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل مستخدم' : 'إضافة مستخدم جديد'),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: _saveUser,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(isEditing ? 'حفظ التغييرات' : 'إنشاء الحساب', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('المعلومات الأساسية', Icons.info_outline_rounded),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'اسم المستخدم',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'يرجى إدخال اسم المستخدم' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        obscureText: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'يرجى إدخال كلمة المرور' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('الصلاحيات والمهام', Icons.security_rounded),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: InputDecoration(
                          labelText: 'الدور الوظيفي',
                          prefixIcon: const Icon(Icons.workspace_premium_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('مستخدم عادي')),
                          DropdownMenuItem(value: 'admin', child: Text('مدير نظام (كامل الصلاحيات)')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _role = val!;
                            if (_role == 'admin') {
                              _selectedPermissions = _allPermissions.map((e) => e['id'] as String).toList();
                            }
                          });
                        },
                      ),
                      if (!isAdmin) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text('حدد الصلاحيات الممنوحة للمستخدم:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        ..._allPermissions.map((p) => _buildPermissionTile(p)),
                      ] else ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('مدير النظام يمتلك كافة الصلاحيات بشكل تلقائي ولا يمكن تقييد وصوله.', style: TextStyle(fontSize: 13))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(Map<String, dynamic> p) {
    final bool isSelected = _selectedPermissions.contains(p['id']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey.shade200),
      ),
      child: CheckboxListTile(
        value: isSelected,
        activeColor: AppTheme.primaryColor,
        onChanged: (val) {
          setState(() {
            if (val == true) {
              _selectedPermissions.add(p['id']);
            } else {
              _selectedPermissions.remove(p['id']);
            }
          });
        },
        title: Text(p['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(p['desc'], style: const TextStyle(fontSize: 12)),
        secondary: Icon(p['icon'], color: isSelected ? AppTheme.primaryColor : Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
