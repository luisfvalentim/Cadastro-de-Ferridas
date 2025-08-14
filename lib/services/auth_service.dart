import 'dart:convert';
import 'package:cadastro_dados/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<AppUser?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

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
      final user = AppUser.fromJson(data['user'], token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      return user;
    } else {
      print('Erro no login: ${response.statusCode} → ${response.body}');
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<bool> updateUser({
    required int id,
    required String name,
    String? password,
    String? role,
  }) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/usuarios/$id');
    final body = {
      'name': name,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
    };

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  static Future<AppUser?> register(
    String name,
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AppUser.fromJson(data, '');
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'Erro de validação';
      throw Exception(message);
    } else {
      throw Exception('Erro ao registrar: ${response.statusCode}');
    }
  }

  static Future<List<AppUser>> getAllUsers() async {
    final token = await getToken();
    if (token == null) throw Exception('Token não encontrado.');

    final url = Uri.parse('$baseUrl/usuarios');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AppUser.fromJson(json, '')).toList();
    } else {
      throw Exception('Erro ao buscar usuários: ${response.body}');
    }
  }

  static Future<bool> toggleUserStatus(int id, bool active) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/usuarios/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'ativo': active}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteUser(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/usuarios/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response.statusCode == 200;
  }
}
