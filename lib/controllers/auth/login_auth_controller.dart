import '../../models/user.dart';
import '../../services/auth/interface/i_login_auth_service.dart';
import 'interface/i_login_auth_controller.dart';

class LoginAuthController implements ILoginAuthController {
  final ILoginAuthService service;

  LoginAuthController(this.service);

  @override
  Future<AppUser?> login(String username, String password) async {
    return await service.login(username, password);
  }
}
