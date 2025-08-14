import '../../services/auth/interface/i_logout_auth_service.dart';
import 'interface/i_logout_auth_controller.dart';

class LogoutAuthController implements ILogoutAuthController {
  final ILogoutAuthService service;

  LogoutAuthController(this.service);

  @override
  Future<void> logout() async {
    await service.logout();
  }
}
