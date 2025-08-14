import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:http/http.dart' as http;
import '../../models/wound.dart';
import 'interfaces/i_update_wound_service.dart';

class UpdateWoundService implements IUpdateWoundService {
  final String baseUrl = AppConfig.apiUrl;

  @override
  Future<bool> update(Wound wound) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/feridas/${wound.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppConfig.token}',
        },
        body: jsonEncode(wound.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erro ao atualizar ferida: $e');
    }
  }
}
