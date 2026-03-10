import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:cadastro_dados/services/image/interface/i_upload_imagem_service.dart';

class UploadImagemController {
  final IUploadImagemService _service;

  UploadImagemController(this._service);

  Future<List<Map<String, dynamic>>> uploadImagens(dynamic imagens) async {
    if (kIsWeb) {
      if (imagens is List<XFile>) {
        return await _service.uploadWeb(imagens);
      } else {
        throw Exception("Para Web, precisa ser List<XFile>");
      }
    } else {
      if (imagens is List<File>) {
        return await _service.upload(imagens);
      } else {
        throw Exception("Para Mobile/Desktop, precisa ser List<File>");
      }
    }
  }
}
