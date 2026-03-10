import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:cadastro_dados/services/image/interface/i_list_imagem_service.dart';
import 'package:http/http.dart' as http;

class ListImagemService implements IListImagemService {
  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final url = Uri.parse('${AppConfig.apiUrl}/imagens');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AppConfig.token}',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        throw Exception("Resposta inesperada do servidor");
      }
    } else if (response.statusCode == 401) {
      throw Exception("Não autorizado: token inválido ou expirado");
    } else {
      throw Exception("Erro ao buscar imagens: ${response.statusCode}");
    }
  }
}
