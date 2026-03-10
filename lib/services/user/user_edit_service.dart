import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../models/user.dart';
import 'interface/i_user_edit_service.dart';

class UpdateUserService implements IUpdateUserService {
  @override
  Future<AppUser?> updateUser(
    int id,
    String name,
    String username, {
    String? role,
    String? password,
  }) async {
    final token = AppConfig.token;
    if (token == null || token.isEmpty) {
      throw const HttpException('Faça login para continuar.');
    }

    final url = Uri.parse('${AppConfig.apiUrl}/usuarios/$id');

    final body = <String, dynamic>{
      'name': name,
      'username': username,
      if (role != null && role.isNotEmpty) 'role': role,
      if (password != null && password.isNotEmpty) 'password': password,
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw const HttpException('Resposta inválida do servidor.');
      }
      return AppUser.fromApiUser(userJson);
    }

    if (response.statusCode == 403) {
      throw const HttpException('Sem permissão para editar este usuário.');
    }

    if (response.statusCode == 422) {
      try {
        final m = jsonDecode(response.body) as Map<String, dynamic>;
        final buffer = StringBuffer(m['message'] ?? 'Dados inválidos.');
        final errs = (m['errors'] as Map?)?.cast<String, dynamic>();
        if (errs != null) {
          errs.forEach((k, v) {
            if (v is List && v.isNotEmpty) buffer.writeln('\n• ${v.first}');
          });
        }
        throw HttpException(buffer.toString().trim());
      } catch (_) {
        throw HttpException('Dados inválidos (422): ${response.body}');
      }
    }

    throw HttpException(
      'Falha ao atualizar (${response.statusCode}): ${response.body}',
    );
  }
}
