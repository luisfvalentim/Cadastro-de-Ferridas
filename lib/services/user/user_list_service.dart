import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../models/user.dart';
import 'interface/i_user_list_service.dart';

class GetAllUsersService implements IGetAllUsersService {
  @override
  Future<List<AppUser>> getAllUsers() async {
    final url = Uri.parse('${AppConfig.apiUrl}/usuarios');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return AppUser.listFromJson(data);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sem permissão para listar usuários.');
    }

    throw Exception(
      'Erro ao obter usuários: '
      '${response.statusCode} ${response.body}',
    );
  }
}
