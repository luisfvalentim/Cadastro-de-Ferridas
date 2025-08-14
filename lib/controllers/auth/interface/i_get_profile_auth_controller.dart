import '../../../models/user.dart';

abstract class IGetProfileAuthController {
  Future<AppUser?> getProfile();
}
