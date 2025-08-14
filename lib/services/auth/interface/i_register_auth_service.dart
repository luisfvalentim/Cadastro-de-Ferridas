import '../../../models/user.dart';

abstract class IRegisterAuthService {
  Future<AppUser?> register(String name, String username, String password);
}
