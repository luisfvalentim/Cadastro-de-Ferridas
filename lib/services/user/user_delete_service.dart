import 'package:http/http.dart' as http;
import '../../config/config.dart';
import 'interface/i_user_delete_service.dart';

class DeleteUserService implements IDeleteUserService {
  @override
  Future<bool> deleteUser(int id) async {
    final url = Uri.parse('${AppConfig.apiUrl}/usuarios/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${AppConfig.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro ao deletar usuário: ${response.body}');
      return false;
    }
  }
}
