// controllers/user/interface/i_update_user_controller.dart
import '../../../models/user.dart';

abstract class IUpdateUserController {
  Future<AppUser?> updateUser({
    required int id,
    required String name,
    required String username,
    String? role,
    String? password,
  });
}
