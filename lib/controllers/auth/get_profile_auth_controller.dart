import 'package:cadastro_dados/services/auth/interface/i_profile_auth_service.dart';
import '../../models/user.dart';
import 'interface/i_get_profile_auth_controller.dart';

class GetProfileAuthController implements IGetProfileAuthController {
  final IGetProfileAuthService service;

  GetProfileAuthController(this.service);

  @override
  Future<AppUser?> getProfile() async {
    return await service.getProfile();
  }
}
