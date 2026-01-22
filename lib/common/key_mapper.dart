import 'dart:convert';

import 'package:flutter/services.dart';

class KeyMapper {
  static late final Map<String, String> _map;
  static bool _initialized = false;

  /// Gọi 1 lần DUY NHẤT khi app start
  static Future<void> init() async {
    if (_initialized) return;

    final jsonStr = await rootBundle.loadString('assets/keymap/keymap580.json');
    _map = Map<String, String>.from(jsonDecode(jsonStr));
    _initialized = true;
  }

  static String convert(String input) {
    if (!_initialized) {
      throw Exception('KeyMapper not initialized');
    }

    final regExp = RegExp(r'\[[^\]]+\]');
    return input.replaceAllMapped(regExp, (m) {
      return _map[m.group(0)] ?? '';
    });
  }
}
