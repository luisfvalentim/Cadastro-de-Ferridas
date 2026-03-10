import 'package:cadastro_dados/controllers/image/interface/i_delete_imagem_controller.dart';
import 'package:cadastro_dados/services/image/interface/i_delete_imagem_service.dart';

class DeleteImagemController implements IDeleteImagemController {
  final IDeleteImagemService service;

  DeleteImagemController(this.service);

  @override
  Future<bool> delete(int id) async {
    return await service.delete(id);
  }
}
