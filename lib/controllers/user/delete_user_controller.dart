import '../../services/user/interface/i_delete_user_service.dart';
import 'interface/i_delete_user_controller.dart';

class DeleteUserController implements IDeleteUserController {
  final IDeleteUserService service;

  DeleteUserController(this.service);

  @override
  Future<bool> deleteUser(int id) async {
    return await service.deleteUser(id);
  }
}
