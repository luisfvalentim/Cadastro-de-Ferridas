import 'dart:io';

abstract class IUploadImagemController {
  Future<List<Map<String, dynamic>>> uploadImagens(List<File> imagens);
}
