import 'package:flutter/material.dart';
import '../../model/UserModel.dart';
import '../../services/AuthService.dart';
import '../../theme/app_theme.dart';
import 'add_user_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = AuthService().getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
            onPressed: () => _navigateToEdit(null),
            tooltip: 'إضافة مستخدم جديد',
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    bool isAdmin = user.role == 'admin';
    bool isMainAdmin = user.username == 'admin';
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade100)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isAdmin ? Colors.amber : AppTheme.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person_rounded, 
                  color: isAdmin ? Colors.amber.shade800 : AppTheme.primaryColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.amber.shade100 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAdmin ? "مدير نظام" : "مستخدم",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, 
                          color: isAdmin ? Colors.amber.shade900 : Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 32, thickness: 1, indent: 8, endIndent: 8),
              _buildPermissionsSummary(user),
              const SizedBox(width: 16),
              if (!isMainAdmin)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                      onPressed: () => _navigateToEdit(user),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () => _handleDeleteUser(user),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsSummary(UserModel user) {
    if (user.role == 'admin' || user.permissions.contains('all')) {
      return const Expanded(
        child: Text('كامل الصلاحيات الاستكشافية', style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }
    
    final Map<String, IconData> icons = {
      'patients': Icons.people_outline,
      'accounting': Icons.account_balance_wallet_outlined,
      'reports': Icons.bar_chart_outlined,
      'employees': Icons.badge_outlined,
      'settings': Icons.settings_outlined,
    };

    return Expanded(
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: user.permissions.map((p) => Icon(icons[p] ?? Icons.circle, size: 20, color: Colors.blueGrey.shade300)).toList(),
      ),
    );
  }

  void _navigateToEdit(UserModel? user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserPage(user: user)),
    );
    if (result == true) _refreshUsers();
  }

  void _handleDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المستخدم', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.username}" نهائياً؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().deleteUser(user.id!);
              _refreshUsers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف الآن'),
          ),
        ],
      ),
    );
  }
}

