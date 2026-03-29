/// نموذج بيانات العيادة
/// يحتوي على معلومات العيادة الواحدة
class ClinicModel {
  final String name; // اسم العيادة
  final String dbFileName; // اسم ملف قاعدة البيانات
  final String? description; // وصف العيادة (اختياري)
  final DateTime createdAt; // تاريخ إنشاء العيادة
  final DateTime? lastAccessedAt; // آخر وقت تم الوصول للعيادة

  ClinicModel({
    required this.name,
    required this.dbFileName,
    this.description,
    DateTime? createdAt,
    this.lastAccessedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// تحويل النموذج إلى خريطة
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dbFileName': dbFileName,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    };
  }

  /// إنشاء نموذج من خريطة
  factory ClinicModel.fromMap(Map<String, dynamic> map) {
    return ClinicModel(
      name: map['name'] as String,
      dbFileName: map['dbFileName'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      lastAccessedAt: DateTime.tryParse(map['lastAccessedAt'] as String? ?? ''),
    );
  }

  /// العرض الودود للنموذج (للتصحيح)
  @override
  String toString() {
    return 'Clinic(name: $name, db: $dbFileName, created: ${createdAt.year}-${createdAt.month}-${createdAt.day})';
  }

  /// التحقق من المساواة
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicModel &&
          runtimeType == other.runtimeType &&
          dbFileName == other.dbFileName;

  /// كود التجزئة
  @override
  int get hashCode => dbFileName.hashCode;

  /// إنشاء نسخة معدلة من النموذج
  ClinicModel copyWith({
    String? name,
    String? dbFileName,
    String? description,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  }) {
    return ClinicModel(
      name: name ?? this.name,
      dbFileName: dbFileName ?? this.dbFileName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  /// الحصول على اسم العيادة بدون امتداد .db
  String get displayName {
    if (dbFileName.endsWith('.db')) {
      return dbFileName.substring(0, dbFileName.length - 3);
    }
    return dbFileName;
  }
}
