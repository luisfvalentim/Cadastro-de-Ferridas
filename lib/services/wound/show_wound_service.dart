import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:http/http.dart' as http;
import '../../models/wound.dart';
import 'interfaces/i_show_wound_service.dart';

class ShowWoundService implements IShowWoundService {
  final String baseUrl = AppConfig.apiUrl;

  @override
  Future<Wound> getById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feridas/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Wound.fromJson(data);
      } else {
        throw Exception('Ferida não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao buscar ferida: $e');
    }
  }
}
