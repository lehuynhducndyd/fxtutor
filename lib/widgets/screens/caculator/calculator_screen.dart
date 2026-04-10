import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Dùng inappwebview thay cho webview_flutter
import 'package:gal/gal.dart';
import 'package:url_launcher/url_launcher.dart'; // Dùng để mở link tải trên Chrome/Safari

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});
  static const String route = 'CalculatorScreen';

  @override
  Widget build(BuildContext context) {
    // Xác định màn hình lớn (chiều rộng >= 800)
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      // Nếu là màn hình lớn thì gán appBar = null để ẩn hoàn toàn
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: const Text('Lấy Keylog/Screenshoot'),
              elevation: 0,
            ),
      body: const KeepAliveWebView(url: 'https://calc-emu.vercel.app/'),
    );
  }
}

class KeepAliveWebView extends StatefulWidget {
  final String url;

  const KeepAliveWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<KeepAliveWebView> createState() => _KeepAliveWebViewState();
}

class _KeepAliveWebViewState extends State<KeepAliveWebView> with AutomaticKeepAliveClientMixin {
  InAppWebViewController? _webViewController;

  // Giữ cho WebView không bị load lại khi chuyển tab/màn hình
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // BẮT BUỘC gọi hàm này

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: InAppWebViewSettings(
        useOnDownloadStart: true, // Bật tính năng lắng nghe tải xuống
        javaScriptEnabled: true, // Bật JS để chạy lệnh bẻ khóa ảnh
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;

        // --- ĐĂNG KÝ KÊNH NHẬN ẢNH TỪ JAVASCRIPT ---
        controller.addJavaScriptHandler(
          handlerName: 'downloadBlob',
          callback: (args) async {
            if (args.isNotEmpty) {
              String base64Data = args[0];
              await _saveImageToGallery(base64Data);
            }
          },
        );
      },
      onDownloadStartRequest: (controller, downloadRequest) async {
        final String url = downloadRequest.url.toString();

        try {
          if (url.startsWith('data:')) {
            // Trường hợp 1: Web trả thẳng mã Base64
            await _saveImageToGallery(url);
          } else if (url.startsWith('blob:')) {
            // Trường hợp 2: Bẻ khóa link Blob bằng Javascript
            String js =
                '''
              var xhr = new XMLHttpRequest();
              xhr.open('GET', '$url', true);
              xhr.responseType = 'blob';
              xhr.onload = function(e) {
                if (this.status == 200) {
                  var blob = this.response;
                  var reader = new FileReader();
                  reader.readAsDataURL(blob);
                  reader.onloadend = function() {
                    var base64data = reader.result;
                    // Gửi mã ảnh về cho Flutter qua kênh 'downloadBlob'
                    window.flutter_inappwebview.callHandler('downloadBlob', base64data);
                  }
                }
              };
              xhr.send();
            ''';
            await controller.evaluateJavascript(source: js);
          } else {
            // Trường hợp 3: Link tải file bình thường (http/https)
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              _showToast('Không thể xử lý link tải này');
            }
          }
        } catch (e) {
          _showToast('Lỗi xử lý tải về: $e');
        }
      },
    );
  }

  // --- HÀM LƯU ẢNH BẰNG THƯ VIỆN GAL MỚI ---
  Future<void> _saveImageToGallery(String base64String) async {
    try {
      _showToast('Đang lưu ảnh vào máy...');

      final parts = base64String.split(',');
      if (parts.length != 2) return;

      final bytes = base64Decode(parts[1]);

      // Kiểm tra và xin quyền tự động bằng thư viện gal
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          _showToast('Cần cấp quyền để lưu ảnh!');
          return;
        }
      }

      // Lưu thẳng ảnh vào bộ sưu tập
      await Gal.putImageBytes(
        bytes,
        name: "fxtutor_keylog_${DateTime.now().millisecondsSinceEpoch}",
      );

      _showToast('Đã lưu ảnh thành công vào Thư viện!');
    } catch (e) {
      _showToast('Lỗi xử lý ảnh: $e');
    }
  }

  // Hàm hiển thị thông báo SnackBar
  void _showToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
}
