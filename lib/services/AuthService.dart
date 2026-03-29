import 'package:hussam_clinc/db/dbhelper.dart';
import '../model/UserModel.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  // Session timeout: 3 hours (180 minutes = 10800 seconds)
  static const int sessionTimeoutMinutes = 180;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !_isSessionExpired();
  bool get isAdmin => _currentUser?.role == 'admin';

  /// Check if the current session has expired
  bool _isSessionExpired() {
    if (_currentUser == null) return false;

    final now = DateTime.now();
    final sessionDuration = now.difference(_currentUser!.loginTime).inMinutes;

    return sessionDuration >= sessionTimeoutMinutes;
  }

  /// Get remaining session time in minutes
  int getSessionRemainingMinutes() {
    if (_currentUser == null) return 0;

    final now = DateTime.now();
    final elapsedMinutes = now.difference(_currentUser!.loginTime).inMinutes;
    final remaining = sessionTimeoutMinutes - elapsedMinutes;

    return remaining > 0 ? remaining : 0;
  }

  /// Check if session is about to expire (warning threshold: 10 minutes)
  bool isSessionAboutToExpire() {
    return getSessionRemainingMinutes() <= 10;
  }

  Future<bool> login(String username, String password) async {
    final db = await DbHelper().getDatabase();
    if (db == null) {
      // Fallback for Web/platforms without SQLite
      if (username == 'admin' && password == 'admin') {
        _currentUser = UserModel(
          id: 1,
          username: 'admin',
          password: 'admin',
          role: 'admin',
          permissions: ['all'],
          isActive: true,
          loginTime: DateTime.now(),
        );
        return true;
      }
      return false; // Fail gracefully if no DB and no admin match
    }

    final res = await db.query(
      'users',
      where: 'username = ? AND password = ? AND is_active = 1',
      whereArgs: [username, password],
    );

    if (res.isNotEmpty) {
      _currentUser = UserModel.fromMap(res.first);
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }

  /// Automatic logout if session has expired
  void autoLogoutIfSessionExpired() {
    if (_isSessionExpired()) {
      logout();
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await DbHelper().getDatabase();
    if (db == null) return [];
    final res = await db.query('users');
    return res.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<void> addUser(UserModel user) async {
    final db = await DbHelper().getDatabase();
    if (db == null) return;
    await db.insert('users', user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    final db = await DbHelper().getDatabase();
    if (db == null) return;
    await db.update('users', user.toMap(),
        where: 'user_id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteUser(int id) async {
    final db = await DbHelper().getDatabase();
    if (db == null) return;
    await db.delete('users',
        where: 'user_id = ? AND username != ?', whereArgs: [id, 'admin']);
  }
}
