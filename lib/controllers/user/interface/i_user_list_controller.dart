import '../../../models/user.dart';

abstract class IGetAllUsersController {
  Future<List<AppUser>> getAllUsers();
}
