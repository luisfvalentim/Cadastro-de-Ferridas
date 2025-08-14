import '../../models/wound.dart';
import '../../services/wound/interfaces/i_create_wound_service.dart';
import 'interfaces/i_create_wound_controller.dart';

class CreateWoundController implements ICreateWoundController {
  final ICreateWoundService _service;

  CreateWoundController(this._service);

  @override
  Future<bool> create(Wound wound) async {
    try {
      return await _service.create(wound);
    } catch (e) {
      throw Exception('Erro ao criar ferida: $e');
    }
  }
}
