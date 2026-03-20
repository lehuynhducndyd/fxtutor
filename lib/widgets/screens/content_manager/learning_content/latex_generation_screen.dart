import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../services/ai_chat_service.dart';
import 'casio_qr.dart';

// Nhớ import AiChatService của bạn vào đây nhé
// import 'package:fx_tutor/services/ai_chat_service.dart';

class LatexGeneratorScreen extends StatefulWidget {
  const LatexGeneratorScreen({super.key});

  static const String route = 'LatexGeneratorScreen';

  @override
  State<LatexGeneratorScreen> createState() => _LatexGeneratorScreenState();
}

class _LatexGeneratorScreenState extends State<LatexGeneratorScreen> {
  final TextEditingController _inputController = TextEditingController();

  // Khởi tạo service AI của bạn (nhớ tùy chỉnh lại tên biến/class cho đúng dự án)
  final AiChatService _aiService = AiChatService();

  bool _isLoading = false;
  String _latexResult = '';

  // Hàm gọi AI để lấy mã LaTeX
  Future<void> _generateLatex() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung cần chuyển đổi!')),
      );
      return;
    }

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _latexResult = ''; // Xóa kết quả cũ
    });

    try {
      // TODO: Mở comment dòng dưới khi bạn đã nối với file AiChatService
      String result = await _aiService.convertToLatex(input);

      // TẠM THỜI MOCK DATA ĐỂ BẠN TEST GIAO DIỆN:

      setState(() {
        _latexResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm copy mã LaTeX
  void _copyToClipboard() {
    if (_latexResult.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _latexResult));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép mã LaTeX!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tạo mã LaTeX'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= 1. Ô NHẬP LIỆU =================
            Text(
              "Nhập văn bản hoặc biểu thức",
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                hintText: "VD: hệ phương trình x+y=2 và x-y=0 ...",
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // NÚT TẠO MÃ
            FilledButton.icon(
              onPressed: _isLoading ? null : _generateLatex,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_isLoading ? "Đang xử lý..." : "Chuyển sang LaTeX"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, CasioQr.route);
              },
              icon: const Icon(Icons.qr_code),
              label: Text("Lấy Latex từ Casio (chỉ fx-880BTG)"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
            const SizedBox(height: 16),

            // KẾT QUẢ CHỈ HIỂN THỊ KHI CÓ DATA
            if (_latexResult.isNotEmpty) ...[
              // ================= 2. Ô HIỂN THỊ CODE (CÓ COPY) =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mã LaTeX",
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text("Copy nhanh"),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: SelectableText(
                  _latexResult,
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
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  // Dùng SingleChildScrollView hướng ngang để công thức dài không bị tràn màn hình
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      _latexResult,
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
            ] else if (!_isLoading) ...[
              // Placeholder khi chưa có kết quả
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.functions_rounded, size: 48, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        "Nhập biểu thức và bấm 'Chuyển sang LaTeX' để xem kết quả.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
