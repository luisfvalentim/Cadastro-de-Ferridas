// controllers/user/update_user_controller.dart
import '../../models/user.dart';
import '../../services/user/interface/i_user_edit_service.dart';
import 'interface/i_user_edit_controller.dart';

class UpdateUserController implements IUpdateUserController {
  final IUpdateUserService service;

  UpdateUserController(this.service);

  @override
  Future<AppUser?> updateUser({
    required int id,
    required String name,
    required String username,
    String? role, // <- opcional
    String? password, // <- opcional
  }) {
    return service.updateUser(
      id,
      name,
      username,
      role: role,
      password: password,
    );
  }
}
