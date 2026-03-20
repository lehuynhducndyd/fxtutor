import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

class CasioQRParser {
  late JavascriptRuntime _jsRuntime;
  bool _isInitialized = false;

  // 1. Chỉ gọi hàm này 1 lần duy nhất (ví dụ: trong initState)
  Future<void> initEngine() async {
    if (_isInitialized) return;

    _jsRuntime = getJavascriptRuntime();

    // Nạp Polyfill
    _jsRuntime.evaluate("""
      class URL {
        constructor(urlStr) {
          var baseSplit = urlStr.split('?');
          this.search = baseSplit.length > 1 ? '?' + baseSplit[1] : '';
          var pathStart = urlStr.indexOf('://');
          var pathWithoutProto = pathStart > -1 ? urlStr.substring(pathStart + 3) : urlStr;
          this.pathname = pathWithoutProto.substring(pathWithoutProto.indexOf('/'), pathWithoutProto.indexOf('?'));
        }
      }
    """);

    // Đọc và nạp thư viện cwqr
    String cwqrScript = await rootBundle.loadString('assets/js/cwqr.js');
    _jsRuntime.evaluate(cwqrScript);

    _isInitialized = true;
  }

  // 2. Hàm này gọi bao nhiêu lần cũng được, chạy cực nhanh
  Map<String, dynamic> parse(String casioUrl) {
    if (!_isInitialized) {
      throw Exception("Vui lòng gọi initEngine() trước khi parse!");
    }

    try {
      String safeUrl = casioUrl.replaceAll("'", "\\'");
      JsEvalResult jsResult = _jsRuntime.evaluate("""
        JSON.stringify(cwqr.parseUrl('$safeUrl', 'en'))
      """);

      if (jsResult.isError) {
        return {"error": true, "message": "JS Evaluation failed"};
      }
      print(jsonDecode(jsResult.stringResult).toString());
      return jsonDecode(jsResult.stringResult);
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // 3. Gọi hàm này khi đóng màn hình (trong dispose() của State)
  void dispose() {
    if (_isInitialized) {
      _jsRuntime.dispose();
      _isInitialized = false;
    }
  }
}
