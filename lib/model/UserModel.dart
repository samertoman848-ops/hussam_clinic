import 'dart:convert';

class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin' or 'user'
  final List<String> permissions;
  final bool isActive;
  final DateTime loginTime;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.permissions = const [],
    this.isActive = true,
    DateTime? loginTime,
  }) : loginTime = loginTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'username': username,
      'password': password,
      'role': role,
      'permissions': jsonEncode(permissions),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    List<String> perms = [];
    try {
      if (map['permissions'] != null) {
        perms = List<String>.from(jsonDecode(map['permissions']));
      }
    } catch (_) {}

    return UserModel(
      id: map['user_id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      permissions: perms,
      isActive: map['is_active'] == 1,
    );
  }

  bool hasPermission(String section) {
    if (role == 'admin' || permissions.contains('all')) return true;
    return permissions.contains(section);
  }
}
