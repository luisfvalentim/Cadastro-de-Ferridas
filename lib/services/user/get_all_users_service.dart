import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../models/user.dart';
import 'interface/i_get_all_users_service.dart';

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
      return data
          .map((json) => AppUser.fromJson(json, AppConfig.token ?? ''))
          .toList();
    } else {
      print('Erro ao obter usuários: ${response.body}');
      return [];
    }
  }
}
