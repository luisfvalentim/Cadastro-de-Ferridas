import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:http/http.dart' as http;
import '../../models/wound.dart';
import 'interfaces/i_search_wounds_service.dart';

class SearchWoundsService implements ISearchWoundsService {
  final String baseUrl = AppConfig.apiUrl;

  @override
  Future<List<Wound>> search(Map<String, dynamic> filtros) async {
    final uri = Uri.parse('$baseUrl/feridas').replace(queryParameters: filtros);

    try {
      final response = await http.get(
        uri,
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
        throw Exception('Erro na busca de feridas');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}
