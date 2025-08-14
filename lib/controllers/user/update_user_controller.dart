import '../../models/user.dart';
import '../../services/user/interface/i_update_user_service.dart';
import 'interface/i_update_user_controller.dart';

class UpdateUserController implements IUpdateUserController {
  final IUpdateUserService service;

  UpdateUserController(this.service);

  @override
  Future<AppUser?> updateUser({
    required int id,
    required String name,
    required String username,
    required String role,
  }) async {
    return await service.updateUser(id, name, username, role);
  }
}
