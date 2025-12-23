import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KeepAliveWebView extends StatefulWidget {
  final String url;

  const KeepAliveWebView({Key? key, required this.url}) : super(key: key);

  @override
  State<KeepAliveWebView> createState() => _KeepAliveWebViewState();
}

// 1. Thêm 'with AutomaticKeepAliveClientMixin' vào State class
class _KeepAliveWebViewState extends State<KeepAliveWebView> with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller tại đây
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  // 2. Override getter 'wantKeepAlive' và trả về 'true'
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // 3. BẮT BUỘC gọi super.build(context)
    super.build(context);

    return WebViewWidget(controller: _controller);
  }
}
