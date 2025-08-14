import 'package:cadastro_dados/controllers/paciente/interface/i_get_paciente_by_id_controller.dart';
import 'package:cadastro_dados/services/paciente/interface/i_get_paciente_by_id_serivice.dart';

class GetPacienteByIdController implements IGetPacienteByIdController {
  final IGetPacienteByIdService service;

  GetPacienteByIdController(this.service);

  @override
  Future<Map<String, dynamic>?> buscarPaciente(String idTexto) async {
    final id = int.tryParse(idTexto);
    if (id == null) return null;
    return await service.getPacienteById(id);
  }
}
