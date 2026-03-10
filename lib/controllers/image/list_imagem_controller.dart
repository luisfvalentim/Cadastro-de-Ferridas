import 'package:cadastro_dados/services/image/interface/i_list_imagem_service.dart';

class ListImagemController {
  final IListImagemService _service;

  ListImagemController(this._service);

  Future<List<Map<String, dynamic>>> listar() async {
    return await _service.getAll();
  }
}
