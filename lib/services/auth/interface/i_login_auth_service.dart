import '../../../models/user.dart';

abstract class ILoginAuthService {
  Future<AppUser?> login(String username, String password);
}
