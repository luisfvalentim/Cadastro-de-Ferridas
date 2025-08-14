import '../../models/wound.dart';
import 'interfaces/i_show_wound_controller.dart';
import '../../services/wound/interfaces/i_show_wound_service.dart';

class ShowWoundController implements IShowWoundController {
  final IShowWoundService _service;

  ShowWoundController(this._service);

  @override
  Future<Wound> show(int id) {
    return _service.getById(id);
  }
}
