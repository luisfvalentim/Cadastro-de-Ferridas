import '../../models/user.dart';
import '../../services/auth/interface/i_register_auth_service.dart';
import 'interface/i_register_auth_controller.dart';

class RegisterAuthController implements IRegisterAuthController {
  final IRegisterAuthService service;

  RegisterAuthController(this.service);

  @override
  Future<AppUser?> register(
    String name,
    String username,
    String password,
  ) async {
    return await service.register(name, username, password);
  }
}
