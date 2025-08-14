import '../../../models/user.dart';

abstract class IGetAllUsersService {
  Future<List<AppUser>> getAllUsers();
}
