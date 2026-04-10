import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';
// Đảm bảo đường dẫn này đúng tới file latex.dart bạn đã tạo
import 'package:fx_tutor/common/latex.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';

// --- IMPORT CÁC FILE CỦA BẠN ---
import '../../../../common/key_mapper.dart';
import '../../../../models/learning_content.dart';
import '../../../../models/user_model.dart';
import '../../../../services/learning_content_service.dart';

class LearningDetailScreen extends StatefulWidget {
  final LearningContent content;
  final UserModel? user;

  const LearningDetailScreen({super.key, required this.content, this.user});

  static const String route = 'LearningDetailScreen';

  @override
  State<LearningDetailScreen> createState() => _LearningDetailScreenState();
}

class _LearningDetailScreenState extends State<LearningDetailScreen> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _userFuture = Future.value(widget.user);
    } else if (widget.content.userId != null && widget.content.userId!.isNotEmpty) {
      _userFuture = context.read<LearningService>().getUserById(widget.content.userId!);
    } else {
      _userFuture = Future.value(null);
    }
  }

  // --- HÀM HỖ TRỢ MAP MÀU TỪ JSON ---
  Color _mapColor(String? colorStr, ColorScheme defaultScheme) {
    switch (colorStr) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      // Trả về màu mặc định theo Theme sáng/tối của máy
      default:
        return defaultScheme.onSurface;
    }
  }

  // --- HÀM HỖ TRỢ MAP KÍCH THƯỚC TỪ JSON ---
  double _mapSize(String? sizeStr) {
    switch (sizeStr) {
      case 'small':
        return 14.0;
      case 'large':
        return 20.0;
      default:
        return 16.0; // medium
    }
  }

  String disableMarkdown(String input) {
    // 1. Thoát các ký tự định dạng Markdown phổ biến
    String escaped = input
        .replaceAll('\\', r'\\') // Thoát chính dấu \ trước tiên
        .replaceAll('#', r'\#') // Tiêu đề
        .replaceAll('*', r'\*') // In đậm, in nghiêng, list
        .replaceAll('_', r'\_') // In nghiêng, gạch chân
        .replaceAll('>', r'\>') // Trích dẫn (Blockquote)
        .replaceAll('-', r'\-') // Gạch đầu dòng
        .replaceAll('+', r'\+') // Gạch đầu dòng
        .replaceAll('`', r'\`'); // Code block

    // 2. Xử lý danh sách đánh số (1. 2. 3. ...)
    // Tìm tất cả các con số theo sau là dấu chấm (vd: "1.", "12.") và chèn dấu \ vào giữa
    escaped = escaped.replaceAllMapped(
      RegExp(r'(\d+)\.'),
      (match) => '${match.group(1)}\\.',
    );

    return escaped;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.content.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER: THÔNG TIN TÁC GIẢ =================
            FutureBuilder<UserModel?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
                }

                String authorName = "Ẩn danh";
                String authorEmail = "Chưa rõ email";

                if (snapshot.hasData && snapshot.data != null) {
                  authorName = snapshot.data!.fullName ?? "Người dùng";
                  authorEmail = snapshot.data!.email ?? "";
                } else if (widget.content.userId != null) {
                  authorName = widget.content.userId!;
                }

                return Card(
                  elevation: 0,
                  color: colorScheme.secondaryContainer.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        child: const Icon(Icons.edit_square, size: 20),
                      ),
                      title: Text(
                        "Tác giả: $authorName",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: authorEmail.isNotEmpty
                          ? Text(authorEmail, style: const TextStyle(fontSize: 12))
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ================= NỘI DUNG BÀI HỌC (BLOCKS) =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.content.blocks.map((block) => _buildBlock(context, block)).toList(),
            ),

            const SizedBox(height: 40), // Khoảng trống dưới cùng cho thoáng
          ],
        ),
      ),
    );
  }

  // ================= HÀM HỖ TRỢ VẼ TỪNG KHỐI NỘI DUNG =================
  Widget _buildBlock(BuildContext context, ContentBlock block) {
    final colorScheme = Theme.of(context).colorScheme;

    // Cấu hình chung cho Markdown (Text & Latex)
    final markdownConfig = MarkdownGenerator(
      generators: [latexGenerator], // Kích hoạt Latex generator
      inlineSyntaxList: [LatexSyntax()], // Kích hoạt cú pháp inline $...$
    );

    switch (block.type) {
      case 'text':
        // Đọc các thuộc tính Style từ JSON
        final bool isBold = block.isBold ?? false;
        final bool isItalic = block.isItalic ?? false;
        final bool isUnderline = block.isUnderline ?? false;
        final Color textColor = _mapColor(block.color, colorScheme);
        final double textSize = _mapSize(block.fontSize);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: MarkdownWidget(
            data: disableMarkdown(block.data ?? ''),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            markdownGenerator: markdownConfig,
            config: MarkdownConfig(
              configs: [
                PConfig(
                  textStyle: TextStyle(
                    fontSize: textSize,
                    height: 1.6,
                    color: textColor,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: textColor, // Đổi màu gạch chân cho tiệp với màu chữ
                  ),
                ),
              ],
            ),
          ),
        );

      case 'latex':
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          // Bọc Math.tex bằng SingleChildScrollView để cho phép cuộn ngang
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              "${block.data}",
              textStyle: const TextStyle(fontSize: 17),
            ),
          ),
        );

      case 'image':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  color: colorScheme.surfaceContainerHighest,
                  child: Image.network(
                    block.url ?? '',
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: colorScheme.errorContainer.withOpacity(0.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded, size: 50, color: colorScheme.error),
                          const SizedBox(height: 8),
                          Text("Không tải được ảnh", style: TextStyle(color: colorScheme.error)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (block.caption != null && block.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    block.caption!,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );

      case '580keylog':
      case '880keylog':
        final is580 = block.type == '580keylog';
        final text = is580
            ? KeyMapper.convert(block.data ?? '')
            : KeyMapper.convert2(block.data ?? '');

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: is580 ? 'Casio580' : 'Casio880',
                fontSize: 28, // Phóng to font nút bấm cho dễ nhìn
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              children: [
                TextSpan(text: text),
              ],
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
