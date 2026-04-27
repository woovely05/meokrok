import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(appDatabaseProvider));
});

const _kUserId = 'user_id';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );

  bool get isOnboardingComplete =>
      user != null && user!.height > 0 && user!.age > 0;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _init();
  }

  final UserRepository _repo;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kUserId);
    if (id != null) {
      final user = await _repo.getUserById(id);
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return;
      }
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<String?> login(String email, String password) async {
    try {
      final user = await _repo.login(email.trim(), password);
      if (user == null) return '이메일 또는 비밀번호가 올바르지 않습니다.';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserId, user.id);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (_) {
      return '로그인 중 오류가 발생했습니다.';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final exists = await _repo.emailExists(email.trim());
      if (exists) return '이미 사용 중인 이메일입니다.';
      final user = await _repo.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserId, user.id);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (_) {
      return '회원가입 중 오류가 발생했습니다.';
    }
  }

  Future<void> saveProfile(UserModel updated) async {
    await _repo.updateProfile(updated);
    state = state.copyWith(user: updated);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(userRepositoryProvider));
});
