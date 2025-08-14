import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../models/user.dart';
import 'interface/i_update_user_service.dart';

class UpdateUserService implements IUpdateUserService {
  @override
  Future<AppUser?> updateUser(
    int id,
    String name,
    String username,
    String role,
  ) async {
    final url = Uri.parse('${AppConfig.apiUrl}/usuarios/$id');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'username': username, 'role': role}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AppUser.fromJson(data, AppConfig.token ?? '');
    } else {
      print('Erro ao atualizar usuário: ${response.body}');
      return null;
    }
  }
}
