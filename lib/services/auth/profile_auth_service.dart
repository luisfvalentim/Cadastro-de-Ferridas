import 'dart:convert';
import 'package:cadastro_dados/services/auth/interface/i_profile_auth_service.dart';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../models/user.dart';

class GetProfileAuthService implements IGetProfileAuthService {
  @override
  Future<AppUser?> getProfile() async {
    final url = Uri.parse('${AppConfig.apiUrl}/perfil');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return AppUser.fromJson(data, AppConfig.token ?? '');
    } else {
      print('Erro ao obter perfil: ${response.body}');
      return null;
    }
  }
}
