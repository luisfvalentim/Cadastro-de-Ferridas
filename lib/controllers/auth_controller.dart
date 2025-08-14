import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<AppUser?> login(String username, String password) async {
    final user = await AuthService.login(username, password);
    if (user != null) {
      _currentUser = user;
    }
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    await AuthService.logout();
  }

  Future<AppUser?> register(
    String name,
    String username,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      throw Exception('As senhas não coincidem.');
    }
    final user = await AuthService.register(name, username, password);
    if (user != null) {
      _currentUser = user;
    }
    return user;
  }

  Future<bool> updateUser({
    required int id,
    required String name,
    String? password,
    String? role,
  }) async {
    return await AuthService.updateUser(
      id: id,
      name: name,
      password: password,
      role: role,
    );
  }

  Future<List<AppUser>> getAllUsers() async {
    return await AuthService.getAllUsers();
  }

  Future<bool> toggleUserStatus(int id, bool active) async {
    return await AuthService.toggleUserStatus(id, active);
  }

  Future<bool> deleteUser(int id) async {
    return await AuthService.deleteUser(id);
  }
}
