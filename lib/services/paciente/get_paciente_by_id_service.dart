import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:cadastro_dados/services/paciente/interface/i_get_paciente_by_id_serivice.dart';
import 'package:http/http.dart' as http;

class GetPacienteByIdService implements IGetPacienteByIdService {
  @override
  Future<Map<String, dynamic>?> getPacienteById(int pacienteId) async {
    final url = Uri.parse('${AppConfig.apiUrl}/pacientes/$pacienteId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      return null;
    }
  }
}
