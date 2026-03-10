import '../../services/user/interface/i_user_delete_service.dart';
import 'interface/i_user_delete_controller.dart';

class DeleteUserController implements IDeleteUserController {
  final IDeleteUserService service;

  DeleteUserController(this.service);

  @override
  Future<bool> deleteUser(int id) async {
    return await service.deleteUser(id);
  }
}
