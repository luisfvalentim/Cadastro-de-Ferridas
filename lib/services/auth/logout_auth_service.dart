import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import 'interface/i_logout_auth_service.dart';

class LogoutAuthService implements ILogoutAuthService {
  @override
  Future<void> logout() async {
    final url = Uri.parse('${AppConfig.apiUrl}/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${AppConfig.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('Erro ao fazer logout: ${response.statusCode}');
        print('Corpo: ${response.body}');
      }
    } catch (e) {
      print('Exceção ao fazer logout: $e');
    } finally {
      // ✅ Limpa o token mesmo se falhar
      AppConfig.token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }
}
