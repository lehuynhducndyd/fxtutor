import 'dart:convert';

import 'package:flutter/services.dart';

class KeyMapper {
  static late final Map<String, String> _map1, _map2;
  static bool _initialized = false;

  /// Gọi 1 lần DUY NHẤT khi app start
  static Future<void> init() async {
    if (_initialized) return;

    final jsonStr1 = await rootBundle.loadString('assets/keymap/keymap580.json');
    final jsonStr2 = await rootBundle.loadString('assets/keymap/keymap880.json');
    _map1 = Map<String, String>.from(jsonDecode(jsonStr1));
    _map2 = Map<String, String>.from(jsonDecode(jsonStr2));
    _initialized = true;
  }

  static String convert(String input) {
    if (!_initialized) {
      throw Exception('KeyMapper not initialized');
    }

    final regExp = RegExp(r'\[[^\]]+\]|\((?:[^()]+|\([^()]*\))*\)');
    return input.replaceAllMapped(regExp, (m) {
      return _map1[m.group(0)] ?? '';
    });
  }

  static String convert2(String input) {
    if (!_initialized) {
      throw Exception('KeyMapper not initialized');
    }
    final regExp = RegExp(r'\[[^\]]+\]|\((?:[^()]+|\([^()]*\))*\)');
    return input.replaceAllMapped(regExp, (m) {
      return _map2[m.group(0)] ?? '';
    });
  }
}
