import '../../services/wound/interfaces/i_delete_wound_service.dart';
import 'interfaces/i_delete_wound_controller.dart';

class DeleteWoundController implements IDeleteWoundController {
  final IDeleteWoundService _service;

  DeleteWoundController(this._service);

  @override
  Future<bool> delete(int woundId) async {
    try {
      return await _service.delete(woundId);
    } catch (e) {
      throw Exception('Erro ao deletar ferida: $e');
    }
  }
}
