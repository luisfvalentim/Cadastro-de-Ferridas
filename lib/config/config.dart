import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid)
      return 'http://10.0.2.2:8000/api'; // emulador Android
    return 'http://127.0.0.1:8000/api'; // iOS simulador / desktop
  }

  static String? token;
}
