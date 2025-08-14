import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:http/http.dart' as http;
import '../../models/wound.dart';
import 'interfaces/i_create_wound_service.dart';

class CreateWoundService implements ICreateWoundService {
  final String baseUrl = AppConfig.apiUrl;

  @override
  Future<bool> create(Wound wound) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feridas'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (AppConfig.token != null)
            'Authorization': 'Bearer ${AppConfig.token}',
        },
        body: jsonEncode(wound.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Erro ao criar ferida: $e');
    }
  }
}
