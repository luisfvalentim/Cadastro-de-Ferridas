import '../../services/user/interface/i_toggle_user_status_service.dart';
import 'interface/i_toggle_user_status_controller.dart';

class ToggleUserStatusController implements IToggleUserStatusController {
  final IToggleUserStatusService service;

  ToggleUserStatusController(this.service);

  @override
  Future<bool> toggleUserStatus(int id) async {
    return await service.toggleUserStatus(id);
  }
}
