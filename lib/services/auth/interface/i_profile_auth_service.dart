import '../../../models/user.dart';

abstract class IGetProfileAuthService {
  Future<AppUser?> getProfile();
}
