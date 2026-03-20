import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../services/qr_parse_service.dart';

class CasioQr extends StatefulWidget {
  const CasioQr({super.key});
  static const String route = 'CasioQr';

  @override
  State<CasioQr> createState() => _CasioQrState();
}

class _CasioQrState extends State<CasioQr> {
  Map<String, dynamic> _qrContent = {};

  late CasioQRParser _parser;
  bool _isParserReady = false;

  @override
  void initState() {
    super.initState();
    _parser = CasioQRParser();
    _initParser();
  }

  Future<void> _initParser() async {
    await _parser.initEngine();
    if (mounted) {
      setState(() {
        _isParserReady = true;
      });
    }
  }

  @override
  void dispose() {
    _parser.dispose();
    super.dispose();
  }

  String _getTemplatedLatex() {
    if (_qrContent['result'] != null && _qrContent['result'] is List) {
      for (var item in _qrContent['result']) {
        if (item['name'] == 'templated') {
          return item['latex'] ?? '';
        }
      }
    }
    return '';
  }

  // Component UI giống y hệt phong cách của LatexGeneratorScreen
  Widget _buildLatexSection(String title, String latexCode, BuildContext context) {
    if (latexCode.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ================= 1. TIÊU ĐỀ & NÚT COPY =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: latexCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã sao chép $title!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text("Copy nhanh"),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ================= 2. Ô HIỂN THỊ CODE =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SelectableText(
            latexCode,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
              color: Colors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ================= 3. Ô PREVIEW =================
        Text(
          "Xem trước (Preview)",
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                latexCode,
                mathStyle: MathStyle.display, // Giữ nguyên chuẩn hiển thị toán
                textStyle: const TextStyle(fontSize: 22),
                onErrorFallback: (FlutterMathException e) {
                  return Text(
                    "Lỗi hiển thị: ${e.message}",
                    style: TextStyle(color: colorScheme.error),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32), // Khoảng cách tới phần tiếp theo
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String expression = _qrContent['expression'] ?? '';
    String templated = _getTemplatedLatex();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tạo Latex từ Casio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isParserReady)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),

            // KHI CHƯA QUÉT (Hiển thị Placeholder y hệt LatexGenerator)
            if (_isParserReady && _qrContent.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, size: 48, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        "Bấm nút Quét QR bên dưới để giải mã biểu thức từ máy tính Casio fx-880BTG.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                      Text(
                        "Chỉ khả dụng ở chế độ Calculate (Phép tính thường)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),

            // KHI ĐÃ CÓ KẾT QUẢ
            if (_qrContent.isNotEmpty) ...[
              _buildLatexSection('Biểu thức', expression, context),
              Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 24),
              _buildLatexSection('Kết quả', templated, context),
            ],
            const SizedBox(height: 64),
          ],
        ),
      ),

      // Nút quét QR nổi bật
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_isParserReady) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );

          if (result != null && result is String) {
            final parsedData = _parser.parse(result);

            setState(() {
              _qrContent = parsedData;
            });
          }
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text("Quét mã Casio"),
      ),
    );
  }
}

// 4. Màn hình quét QR (Giữ nguyên)
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dùng Text.rich để tự động nhận màu sắc và kích cỡ chuẩn của AppBar
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "Bấm ",
              ),
              TextSpan(
                text: "q[", // Ký tự map với nút bấm trong font Casio880
                style: const TextStyle(
                  fontFamily: 'Casio880',
                  fontSize: 22, // Bạn có thể chỉnh cho nút bấm to hơn chữ thường một chút
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: " để tạo QR", // Nhớ thêm dấu cách ở đây
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? qrData = barcodes.first.rawValue;
                if (qrData != null) {
                  _controller.stop();
                  Navigator.pop(context, qrData);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
