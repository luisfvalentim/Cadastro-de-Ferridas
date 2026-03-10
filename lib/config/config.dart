import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiUrl {
    // Web/desktop na mesma máquina do backend
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'http://127.0.0.1:8000/api';
    }
    // Emulador Android: 10.0.2.2 aponta para localhost do host
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    // iOS simulador também acessa o host pelo localhost
    if (Platform.isIOS) {
      return 'http://127.0.0.1:8000/api';
    }
    // fallback
    return 'http://127.0.0.1:8000/api';
  }

  static String? token;
}
