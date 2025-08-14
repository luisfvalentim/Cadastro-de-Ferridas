import '../../../models/user.dart';

abstract class IRegisterAuthController {
  Future<AppUser?> register(String name, String username, String password);
}
