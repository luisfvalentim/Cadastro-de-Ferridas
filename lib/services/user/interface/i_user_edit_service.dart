// services/user/interface/i_update_user_service.dart
import '../../../models/user.dart';

abstract class IUpdateUserService {
  Future<AppUser?> updateUser(
    int id,
    String name,
    String username, {
    String? role,
    String? password,
  });
}
