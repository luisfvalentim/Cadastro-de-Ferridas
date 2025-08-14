import 'package:http/http.dart' as http;
import '../../config/config.dart'; // se usar baseUrl aqui
import 'interfaces/i_delete_wound_service.dart';

class DeleteWoundService implements IDeleteWoundService {
  @override
  Future<bool> delete(int woundId) async {
    final url = Uri.parse('${AppConfig.apiUrl}/feridas/$woundId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erro ao deletar ferida: $e');
    }
  }
}
