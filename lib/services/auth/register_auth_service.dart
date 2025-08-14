import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import '../../models/user.dart';
import 'interface/i_register_auth_service.dart';

class RegisterAuthService implements IRegisterAuthService {
  @override
  Future<AppUser?> register(
    String name,
    String username,
    String password,
  ) async {
    final url = Uri.parse('${AppConfig.apiUrl}/register');

    final body = {
      'name': name,
      'username': username,
      'password': password,
      'password_confirmation': password,
    };

    print('🔍 Enviando para API: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('📥 Status: ${response.statusCode}');
    print('📥 Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? '';
      return AppUser.fromJson(data, token);
    } else {
      print('❌ Erro no registro: ${response.body}');
      return null;
    }
  }
}
