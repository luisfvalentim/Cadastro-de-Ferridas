import '../../models/user.dart';
import '../../services/user/interface/i_get_all_users_service.dart';
import 'interface/i_get_all_users_controller.dart';

class GetAllUsersController implements IGetAllUsersController {
  final IGetAllUsersService service;

  GetAllUsersController(this.service);

  @override
  Future<List<AppUser>> getAllUsers() async {
    return await service.getAllUsers();
  }
}
