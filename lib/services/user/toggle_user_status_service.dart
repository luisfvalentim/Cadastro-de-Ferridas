import 'package:http/http.dart' as http;
import '../../config/config.dart';
import 'interface/i_toggle_user_status_service.dart';

class ToggleUserStatusService implements IToggleUserStatusService {
  @override
  Future<bool> toggleUserStatus(int id) async {
    final url = Uri.parse('${AppConfig.apiUrl}/usuarios/$id/status');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro ao alterar status do usuário: ${response.body}');
      return false;
    }
  }
}
