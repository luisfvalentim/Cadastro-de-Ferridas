import 'package:cadastro_dados/controllers/wound/interfaces/i_list_wounds_controller.dart';
import '../../models/wound.dart';
import '../../services/wound/interfaces/i_list_wound_service.dart';

class ListWoundController implements IListWoundController {
  final IListWoundsService _service;

  ListWoundController(this._service);

  @override
  Future<List<Wound>> listAll() async {
    try {
      return await _service.getAll();
    } catch (e) {
      throw Exception('Erro ao listar feridas: $e');
    }
  }
}
