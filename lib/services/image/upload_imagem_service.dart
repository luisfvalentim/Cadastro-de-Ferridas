import 'dart:io';
import 'package:cadastro_dados/config/config.dart';
import 'package:cadastro_dados/services/image/interface/i_upload_imagem_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class UploadImagemService implements IUploadImagemService {
  @override
  Future<List<Map<String, dynamic>>> upload(List<File> imagens) async {
    final url = Uri.parse('${AppConfig.apiUrl}/imagens');
    final request = http.MultipartRequest('POST', url);

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${AppConfig.token}';

    for (var img in imagens) {
      request.files.add(
        await http.MultipartFile.fromPath('imagens[]', img.path),
      );
    }

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return List<Map<String, dynamic>>.from(jsonDecode(body));
    } else {
      throw Exception('Erro no upload: ${response.statusCode} - $body');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> uploadWeb(List<XFile> imagens) async {
    final url = Uri.parse('${AppConfig.apiUrl}/imagens');
    final request = http.MultipartRequest('POST', url);

    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${AppConfig.token}';

    for (var img in imagens) {
      final bytes = await img.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagens[]',
          bytes,
          filename: img.name,
        ),
      );
    }


    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return List<Map<String, dynamic>>.from(jsonDecode(body));
    } else {
      throw Exception('Erro no upload (Web): ${response.statusCode} - $body');
    }
  }
}
