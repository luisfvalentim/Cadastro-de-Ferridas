import '../../../models/user.dart';

abstract class IUpdateUserController {
  Future<AppUser?> updateUser({
    required int id,
    required String name,
    required String username,
    required String role,
  });
}
