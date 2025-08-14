import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:cadastro_dados/services/wound/interfaces/i_list_wound_service.dart';
import 'package:http/http.dart' as http;
import '../../models/wound.dart';

class ListWoundsService implements IListWoundsService {
  final String baseUrl = AppConfig.apiUrl;

  @override
  Future<List<Wound>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feridas'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppConfig.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Wound.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao listar feridas');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}
