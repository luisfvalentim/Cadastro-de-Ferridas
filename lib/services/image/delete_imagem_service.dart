import 'package:cadastro_dados/config/config.dart';
import 'package:cadastro_dados/services/image/interface/i_delete_imagem_service.dart';
import 'package:http/http.dart' as http;

class DeleteImagemService implements IDeleteImagemService {
  final String baseUrl = AppConfig.apiUrl;

  @override
  Future<bool> delete(int id) async {
    final url = Uri.parse('$baseUrl/imagens/$id');

    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AppConfig.token}',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        'Erro ao excluir imagem (status: ${response.statusCode})',
      );
    }
  }
}
