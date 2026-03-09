import 'package:flutter/material.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/services/StorageService.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';

class DbSettingsPage extends StatefulWidget {
  const DbSettingsPage({super.key});

  @override
  State<DbSettingsPage> createState() => _DbSettingsPageState();
}

class _DbSettingsPageState extends State<DbSettingsPage> {
  bool _isMoving = false;

  Future<void> _changeRootPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'اختر المجلد الجديد لنقل البيانات',
    );

    if (selectedDirectory != null) {
      // Show confirmation dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد نقل البيانات'),
          content: Text(
              'هل أنت متأكد من رغبتك في نقل كافة البيانات (قاعدة البيانات، الصور، والتقارير) إلى المجلد المختار؟\n\nالمسار: $selectedDirectory'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('نقل الآن')),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isMoving = true);
        bool success = await StorageService().moveDataTo(selectedDirectory);
        setState(() => _isMoving = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('تم نقل البيانات وتحديث المسارات بنجاح'),
                backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('حدث خطأ أثناء نقل البيانات'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('إعدادات تخزين البيانات'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('المسار الرئيسي الحالي'),
                _buildPathCard(
                    appRootPath, Icons.folder_open, AppTheme.primaryColor),
                const SizedBox(height: 30),
                _buildSectionHeader('تفاصيل المواقع'),
                _buildDetailTile('قاعدة البيانات', extDbFolder, Icons.storage),
                _buildDetailTile('صور الأسنان', extPicFolder, Icons.image),
                _buildDetailTile('التقارير والمستندات', extFilesReports,
                    Icons.picture_as_pdf),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isMoving ? null : _changeRootPath,
                    icon: const Icon(Icons.drive_file_move_outlined),
                    label: const Text('تغيير موقع البيانات ونقلها'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Card(
                  color: Color(0xFFFFF3CD),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'تنبيه: عند تغيير المسار، سيقوم البرنامج بنقل كافة الملفات الحالية إلى الموقع الجديد. يرجى التأكد من توفر مساحة كافية وإغلاق أي ملفات مفتوحة.',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF856404)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isMoving)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text('جاري نقل البيانات... يرجى الانتظار',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildPathCard(String path, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('المسار المعتمد',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  path,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String path, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                Text(path,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
