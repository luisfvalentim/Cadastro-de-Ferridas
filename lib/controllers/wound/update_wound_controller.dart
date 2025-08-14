import '../../models/wound.dart';
import '../../services/wound/interfaces/i_update_wound_service.dart';
import 'interfaces/i_update_wound_controller.dart';

class UpdateWoundController implements IUpdateWoundController {
  final IUpdateWoundService _service;

  UpdateWoundController(this._service);

  @override
  Future<bool> update(Wound wound) async {
    try {
      return await _service.update(wound);
    } catch (e) {
      throw Exception('Erro ao atualizar ferida: $e');
    }
  }
}
