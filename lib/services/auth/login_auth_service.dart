import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import '../../models/user.dart';
import 'interface/i_login_auth_service.dart';

class LoginAuthService implements ILoginAuthService {
  @override
  Future<AppUser?> login(String username, String password) async {
    final url = Uri.parse('${AppConfig.apiUrl}/login');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      AppConfig.token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return AppUser.fromJson(data['user'], token);
    } else {
      print('Erro no login: ${response.body}');
      return null;
    }
  }
}
