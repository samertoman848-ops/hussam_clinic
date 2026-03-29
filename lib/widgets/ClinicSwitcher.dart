import 'package:flutter/material.dart';
import 'package:hussam_clinc/services/ClinicService.dart';
import 'package:hussam_clinc/model/ClinicModel.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/main.dart';

/// واجهة سريعة للتنقل بين العيادات
class ClinicSwitcher extends StatefulWidget {
  final VoidCallback? onClinicChanged;
  final bool showAsIcon;

  const ClinicSwitcher({
    super.key,
    this.onClinicChanged,
    this.showAsIcon = true,
  });

  @override
  State<ClinicSwitcher> createState() => _ClinicSwitcherState();
}

class _ClinicSwitcherState extends State<ClinicSwitcher> {
  final ClinicService _clinicService = ClinicService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    setState(() => _isLoading = true);
    await _clinicService.loadClinics();
    setState(() => _isLoading = false);
  }

  Future<void> _switchClinic(ClinicModel clinic) async {
    setState(() => _isLoading = true);

    final success = await _clinicService.switchToClinic(clinic);

    setState(() => _isLoading = false);

    if (success) {
      // إعادة تحميل البيانات
      widget.onClinicChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التبديل إلى ${clinic.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinics = _clinicService.clinics;

    // إذا كانت عيادة واحدة فقط، لا تعرض الزر
    if (clinics.length <= 1) {
      return const SizedBox.shrink();
    }

    if (widget.showAsIcon) {
      return _buildIconView(clinics);
    }

    return _buildDetailedView(clinics);
  }

  /// عرض الزر كأيقونة صغيرة (للـ AppBar أو الـ Header)
  Widget _buildIconView(List<ClinicModel> clinics) {
    return PopupMenuButton<ClinicModel>(
      icon: const Icon(Icons.business, size: 24),
      tooltip: 'تبديل العيادة',
      enabled: !_isLoading,
      onSelected: _switchClinic,
      itemBuilder: (context) => clinics
          .map((clinic) => PopupMenuItem<ClinicModel>(
                value: clinic,
                child: Row(
                  children: [
                    if (clinic.dbFileName ==
                        _clinicService.currentClinic?.dbFileName)
                      const Icon(Icons.check_circle,
                          color: AppTheme.primaryColor, size: 18)
                    else
                      const Icon(Icons.circle_outlined,
                          color: Colors.grey, size: 18),
                    const SizedBox(width: 12),
                    Text(clinic.name),
                  ],
                ),
              ))
          .toList(),
    );
  }

  /// عرض مفصل (في القائمة الجانبية أو صفحة منفصلة)
  Widget _buildDetailedView(List<ClinicModel> clinics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'العيادات (${clinics.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                onPressed: () => _showAddClinicDialog(context),
                tooltip: 'إضافة عيادة جديدة',
              ),
            ],
          ),
          ...clinics.map((clinic) {
            final isCurrentClinic =
                clinic.dbFileName == _clinicService.currentClinic?.dbFileName;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrentClinic
                        ? AppTheme.primaryColor
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  color: isCurrentClinic
                      ? AppTheme.primaryColor.withOpacity(0.05)
                      : Colors.transparent,
                ),
                child: ListTile(
                  onTap: isCurrentClinic ? null : () => _switchClinic(clinic),
                  leading: Icon(
                    Icons.business,
                    color: isCurrentClinic
                        ? AppTheme.primaryColor
                        : Colors.grey[600],
                    size: 24,
                  ),
                  title: Text(
                    clinic.name,
                    style: TextStyle(
                      fontWeight:
                          isCurrentClinic ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentClinic
                          ? AppTheme.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  subtitle: clinic.lastAccessedAt != null
                      ? Text(
                          'آخر وصول: ${_formatDate(clinic.lastAccessedAt!)}',
                          style: const TextStyle(fontSize: 11),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.orange, size: 20),
                        onPressed: () => _showResetClinicDialog(context, clinic),
                        tooltip: 'تصفير كافة البيانات',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showRenameClinicDialog(context, clinic),
                        tooltip: 'إعادة تسمية',
                      ),
                      if (!isCurrentClinic)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () => _showDeleteClinicDialog(context, clinic),
                          tooltip: 'حذف',
                        ),
                      if (isCurrentClinic)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showResetClinicDialog(
      BuildContext context, ClinicModel clinic) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفير بيانات العيادة'),
        content: Text('هل أنت متأكد من رغبتك في حذف "كافة" البيانات والملفات في عيادة "${clinic.name}"؟\nهذا الإجراء سيقوم بإرجاع العيادة لحالتها الأولى (فارغة) ولا يمكن التراجع عنه.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('تصفير الآن'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      final success = await _clinicService.resetClinic(clinic);
      setState(() => _isLoading = false);

      if (success) {
        // إذا كانت العيادة المصفيرة هي الحالية، نحتاج لتحديث الواجهة بالكامل
        if (clinic.dbFileName == _clinicService.currentClinic?.dbFileName) {
          widget.onClinicChanged?.call();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تصفير بيانات العيادة بنجاح')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل تصفير العيادة. تأكد من إغلاق كافة الاتصالات.')),
          );
        }
      }
    }
  }

  Future<void> _showAddClinicDialog(BuildContext context) async {
    final textController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عيادة جديدة'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'اسم العيادة',
            hintText: 'مثال: عيادة النصر',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result == true && textController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      final success = await _clinicService.createClinic(textController.text);
      setState(() => _isLoading = false);

      if (success) {
        _loadClinics();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء العيادة بنجاح')),
          );
        }
      }
    }
  }

  Future<void> _showRenameClinicDialog(
      BuildContext context, ClinicModel clinic) async {
    final textController = TextEditingController(text: clinic.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تسمية العيادة'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'الاسم الجديد',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تغيير'),
          ),
        ],
      ),
    );

    if (result == true && textController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      final success =
          await _clinicService.renameClinic(clinic, textController.text);
      setState(() => _isLoading = false);

      if (success) {
        _loadClinics();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تغيير الاسم بنجاح')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteClinicDialog(
      BuildContext context, ClinicModel clinic) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العيادة'),
        content: Text('هل أنت متأكد من رغبتك في حذف عيادة "${clinic.name}"؟\nسيتم حذف جميع البيانات المتعلقة بها نهائياً!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      final success = await _clinicService.deleteClinic(clinic);
      setState(() => _isLoading = false);

      if (success) {
        _loadClinics();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف العيادة بنجاح')),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'للتو';
    } else if (difference.inHours < 1) {
      return 'قبل ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'قبل ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}

/// شريط سريع للتنقل بين العيادات (للـ AppBar)
class QuickClinicNavigation extends StatefulWidget {
  final VoidCallback? onClinicChanged;

  const QuickClinicNavigation({
    super.key,
    this.onClinicChanged,
  });

  @override
  State<QuickClinicNavigation> createState() => _QuickClinicNavigationState();
}

class _QuickClinicNavigationState extends State<QuickClinicNavigation> {
  final ClinicService _clinicService = ClinicService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clinicService.loadClinics();
  }

  Future<void> _navigateClinic(bool isNext) async {
    setState(() => _isLoading = true);

    final success = isNext
        ? await _clinicService.switchToNextClinic()
        : await _clinicService.switchToPreviousClinic();

    setState(() => _isLoading = false);

    if (success) {
      widget.onClinicChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم الانتقال إلى: ${_clinicService.currentClinicName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showManageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة العيادات'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: ClinicSwitcher(
              showAsIcon: false,
              onClinicChanged: () {
                Navigator.pop(context);
                widget.onClinicChanged?.call();
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الزر السابق
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
            onPressed: _isLoading ? null : () => _navigateClinic(false),
            tooltip: 'العيادة السابقة',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),

          // اسم العيادة الحالية
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showManageDialog,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.business, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _clinicService.currentClinicName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // الزر التالي
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            onPressed: _isLoading ? null : () => _navigateClinic(true),
            tooltip: 'العيادة التالية',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          
          // إدارة العيادات
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 18),
            onPressed: _showManageDialog,
            tooltip: 'إدارة العيادات',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.only(right: 8, left: 4),
          ),
        ],
      ),
    );
  }
}
