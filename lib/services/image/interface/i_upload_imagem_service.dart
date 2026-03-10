import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class IUploadImagemService {
  Future<List<Map<String, dynamic>>> upload(List<File> imagens);
  Future<List<Map<String, dynamic>>> uploadWeb(List<XFile> imagens);
}
