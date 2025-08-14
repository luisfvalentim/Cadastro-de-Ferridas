import '../../../models/user.dart';

abstract class IUpdateUserService {
  Future<AppUser?> updateUser(
    int id,
    String name,
    String username,
    String role,
  );
}
