import 'package:flutter/material.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/services/StorageService.dart';
import 'package:hussam_clinc/services/DbImportService.dart';
import 'package:hussam_clinc/services/BackupService.dart';
import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class DbSettingsPage extends StatefulWidget {
  const DbSettingsPage({super.key});

  @override
  State<DbSettingsPage> createState() => _DbSettingsPageState();
}

class _DbSettingsPageState extends State<DbSettingsPage> {
  bool _isMoving = false;
  bool _isImporting = false;
  bool _isBackingUp = false;
  List<String> _availableDatabases = [];
  BackupFrequency _backupFrequency = BackupFrequency.none;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _backupFrequency = BackupService().frequency;
    await _loadAvailableDatabases();
  }

  Future<void> _loadAvailableDatabases() async {
    try {
      final dir = Directory(extDbFolder);
      if (await dir.exists()) {
        final files = await dir.list().toList();
        final dbFiles = files
            .whereType<File>()
            .where((f) => f.path.endsWith('.db'))
            .map((f) => p.basename(f.path))
            .toList();
        setState(() {
          _availableDatabases = dbFiles;
        });
      }
    } catch (e) {
      print('Error loading databases: $e');
    }
  }

  Future<void> _switchDatabase(String dbName) async {
    if (dbName == selectedDbName) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تبديل قاعدة البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من رغبتك في التبديل إلى $dbName؟\n\nسيتم إغلاق قاعدة البيانات الحالية وفتح المختارة.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            child: const Text('تبديل')
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DbHelper().closeDB();
      await StorageService().saveDbConfig(dbName);
      await _loadAvailableDatabases();
      await reloadAllData();
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم التحويل إلى $dbName بنجاح'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        setState(() {});
      }
    }
  }

  Future<void> _importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'اختر ملف قاعدة البيانات لاستيراده',
    );

    if (result != null && result.files.single.path != null) {
      String sourcePath = result.files.single.path!;
      
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد استيراد البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              'سيقوم البرنامج بدمج البيانات من الملف المختار مع قاعدة البيانات الحالية.\n\nسيتم تجاهل السجلات المكررة (التي تحمل نفس المعرف). هل تود المتابعة؟'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                child: const Text('بدء الاستيراد')),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isImporting = true);
        
        final importService = DbImportService();
        final importResult = await importService.importFrom(sourcePath);
        
        setState(() => _isImporting = false);

        if (importResult.success) {
          _showImportResultDialog(importResult);
        } else {
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل الاستيراد: ${importResult.message}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          }
        }
      }
    }
  }

  Future<void> _changeRootPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'اختر المجلد الجديد لنقل البيانات',
    );

    if (selectedDirectory != null) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد نقل البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              'هل أنت متأكد من رغبتك في نقل كافة البيانات (قاعدة البيانات، الصور، والتقارير) إلى المجلد المختار؟\n\nالمسار: $selectedDirectory'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                child: const Text('نقل الآن')),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isMoving = true);
        bool success = await StorageService().moveDataTo(selectedDirectory);
        setState(() => _isMoving = false);

        if(mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم نقل البيانات وتحديث المسارات بنجاح'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('حدث خطأ أثناء نقل البيانات'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
            );
          }
        }
      }
    }
  }

  Future<void> _createManualBackup() async {
    setState(() => _isBackingUp = true);
    bool success = await BackupService().createBackup(isManual: true);
    setState(() => _isBackingUp = false);
    if(mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء نسخة احتياطية لكافة العيادات بنجاح في مجلد backups'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل إنشاء النسخة الاحتياطية'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _createNewDatabase() async {
    final TextEditingController nameController = TextEditingController();
    
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء عيادة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أدخل اسم العيادة الجديدة باللغة الإنجليزية (مثال: nasser.db):'),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'اسم العيادة (مثال: roni_clinic)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            child: const Text('إنشاء')
          ),
        ],
      ),
    );

    if (confirm == true && nameController.text.trim().isNotEmpty) {
      String newDbName = nameController.text.trim();
      if (!newDbName.endsWith('.db')) {
        newDbName += '.db';
      }
      
      final dbPath = p.join(extDbFolder, newDbName);
      if (await File(dbPath).exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يوجد عيادة بنفس الاسم مسبقاً!'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      
      try {
        await DbHelper().copyAssetsDb(dbPath);
        await _loadAvailableDatabases();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إنشاء العيادة \$newDbName بنجاح'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ أثناء الإنشاء: \$e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showImportResultDialog(DbImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ملخص عملية الاستيراد', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryRow('إجمالي المستورد:', result.totalImported.toString(), Colors.green),
              _buildSummaryRow('إجمالي المتخطى (مكرر):', result.totalSkipped.toString(), Colors.orange),
              _buildSummaryRow('إجمالي الفاشل:', result.totalFailed.toString(), Colors.red),
              const Divider(height: 30),
              const Text('التفاصيل لكل جدول:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: result.tableResults.length,
                  itemBuilder: (context, index) {
                    final tableName = result.tableResults.keys.elementAt(index);
                    final tableRes = result.tableResults[tableName]!;
                    return ListTile(
                      dense: true,
                      title: Text(tableRes.label),
                      subtitle: Text('استيراد: ${tableRes.imported} | مكرر: ${tableRes.skipped} | خطأ: ${tableRes.failed}'),
                      trailing: tableRes.failed > 0 ? const Icon(Icons.warning, color: Colors.red, size: 16) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              child: const Text('إغلاق')),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 4, top: 20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildBackupSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('نظام النسخ الاحتياطي يوفر حماية لبياناتك ضد الفقدان. يتم حفظ النسخ الاحتياطية في مجلد backups داخل المسار الرئيسي.',
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('جدولة النسخ التلقائي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BackupFrequency>(
                    value: _backupFrequency,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    items: const [
                      DropdownMenuItem(value: BackupFrequency.none, child: Text('متوقف')),
                      DropdownMenuItem(value: BackupFrequency.daily, child: Text('يومياً')),
                      DropdownMenuItem(value: BackupFrequency.weekly, child: Text('أسبوعياً')),
                      DropdownMenuItem(value: BackupFrequency.monthly, child: Text('شهرياً')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => _backupFrequency = val);
                        await BackupService().setFrequency(val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          if (BackupService().lastBackup != null) ...[
            Row(
              children: [
                const Icon(Icons.history, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'آخر نسخة تمت في: ${BackupService().lastBackup.toString().substring(0, 16)}', 
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isBackingUp ? null : _createManualBackup,
              icon: const Icon(Icons.backup),
              label: const Text('أخذ نسخة احتياطية الآن', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildPathsSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPathRow(Icons.folder_special, 'المسار الرئيسي', appRootPath, isMain: true),
          const Divider(height: 24),
          _buildPathRow(Icons.storage, 'قاعدة البيانات', extDbFolder),
          const SizedBox(height: 12),
          _buildPathRow(Icons.image, 'صور الأسنان', extPicFolder),
          const SizedBox(height: 12),
          _buildPathRow(Icons.picture_as_pdf, 'المستندات', extFilesReports),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isMoving || _isImporting ? null : _changeRootPath,
              icon: const Icon(Icons.drive_file_move_outlined),
              label: const Text('تغيير موقع البيانات ونقلها'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathRow(IconData icon, String label, String value, {bool isMain = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: isMain ? AppTheme.primaryColor : Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: isMain ? FontWeight.bold : FontWeight.w600, fontSize: isMain ? 15 : 13, color: isMain ? Colors.black87 : Colors.grey[800])),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatabaseSelectionSection() {
    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('اختر قاعدة البيانات التي تريد العمل عليها، أو أضف قاعدة بيانات جديدة إلى المجلد.',
                  style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
              ),
              IconButton(
                onPressed: _loadAvailableDatabases,
                icon: const Icon(Icons.refresh, color: Colors.blue),
                tooltip: 'تحديث',
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _availableDatabases.isEmpty
                ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لا يوجد قواعد بيانات')))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _availableDatabases.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final dbName = _availableDatabases[index];
                      final isSelected = dbName == selectedDbName;
                      return ListTile(
                        leading: Icon(isSelected ? Icons.check_circle : Icons.storage, 
                                      color: isSelected ? Colors.green : Colors.grey),
                        title: Text(dbName, style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.green[800] : Colors.black87,
                        )),
                        subtitle: isSelected ? const Text('قاعدة بيانات نشطة', style: TextStyle(fontSize: 11, color: Colors.green)) 
                                           : Text('تبديل للنقر', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        trailing: isSelected ? null : TextButton(
                          onPressed: () => _switchDatabase(dbName),
                          child: const Text('تبديل'),
                        ),
                        onTap: isSelected ? null : () => _switchDatabase(dbName),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createNewDatabase,
              icon: const Icon(Icons.add_business),
              label: const Text('إنشاء عيادة جديدة (قاعدة بيانات فارغة)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                if (result != null && result.files.single.path != null) {
                  String path = result.files.single.path!;
                  String name = p.basename(path);
                  await File(path).copy(p.join(extDbFolder, name));
                  await _loadAvailableDatabases();
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم إضافة الملف $name بنجاح'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('إضافة ملف قاعدة بيانات خارجي'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('استيراد بيانات من قاعدة أخرى ودمجها مع البيانات الحالية. مفيد عند نقل البيانات بين العيادات أو الأجهزة.',
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isImporting || _isMoving ? null : _importDatabase,
              icon: const Icon(Icons.import_export),
              label: const Text('اختيار ملف والبدء بالدمج', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إدارة ونسخ البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('النسخ الاحتياطي والأمان', Icons.security, Colors.green[700]!),
                _buildBackupSection(),

                _buildSectionHeader('المسارات والمجلدات', Icons.folder_open, AppTheme.secondaryColor),
                _buildPathsSection(),

                _buildSectionHeader('قواعد البيانات', Icons.storage, Colors.orange[800]!),
                _buildDatabaseSelectionSection(),

                _buildSectionHeader('الاستيراد والدمج', Icons.compare_arrows, Colors.blue[800]!),
                _buildImportSection(),

                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isMoving || _isImporting || _isBackingUp)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                          _isMoving ? 'جاري نقل البيانات...' 
                        : _isBackingUp ? 'جاري عمل نسخة احتياطية...' 
                        : 'جاري دمج البيانات...',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
