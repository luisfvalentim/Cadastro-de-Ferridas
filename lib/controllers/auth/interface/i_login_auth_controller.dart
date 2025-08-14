import '../../../models/user.dart';

abstract class ILoginAuthController {
  Future<AppUser?> login(String username, String password);
}
