import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:fx_tutor/models/learning_content.dart';
import 'package:fx_tutor/models/user_model.dart';
import 'package:fx_tutor/services/learning_content_service.dart';
import 'package:fx_tutor/widgets/screens/home/quiz_screen.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';

import '../../../common/key_mapper.dart';
import '../../../common/latex.dart';
import '../contribute/add_contribute_screen.dart';

class LearningListDetailScreen extends StatefulWidget {
  final LearningContent content;
  const LearningListDetailScreen({super.key, required this.content});

  static const String route = 'LearningListDetailScreen';

  @override
  State<LearningListDetailScreen> createState() => _LearningListDetailScreenState();
}

class _LearningListDetailScreenState extends State<LearningListDetailScreen> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    if (widget.content.userId != null && widget.content.userId!.isNotEmpty) {
      _userFuture = context.read<LearningService>().getUserById(widget.content.userId!);
    } else {
      _userFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.content.title,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  ...widget.content.blocks.map((block) => _buildBlock(context, block)),
                  const SizedBox(height: 24),
                  const SizedBox(height: 12), // Khoảng cách giữa 2 nút
                  // Nút Báo cáo lỗi / Góp ý (Nút phụ)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AddContributeScreen.route);
                    },
                    icon: Icon(Icons.flag_outlined, color: colorScheme.error, size: 20),
                    label: Text(
                      "Báo cáo lỗi / Góp ý bài viết này",
                      style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ), // Khoảng trống dưới cùng cho thoáng
                ],
              ),
            ),
          ),

          // ================= FOOTER: NÚT LÀM TRẮC NGHIỆM =================
          // ================= FOOTER: NÚT BẤM =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Để column ôm khít 2 nút
                children: [
                  // Nút Làm bài Trắc nghiệm (Nút chính)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, QuizScreen.route, arguments: widget.content);
                    },
                    icon: const Icon(Icons.quiz_rounded),
                    label: const Text(
                      "Làm bài Trắc nghiệm",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, ContentBlock block) {
    final colorScheme = Theme.of(context).colorScheme;

    // Cấu hình chung cho Markdown (Text & Latex)
    final markdownConfig = MarkdownGenerator(
      generators: [latexGenerator], // Kích hoạt Latex generator
      inlineSyntaxList: [LatexSyntax()], // Kích hoạt cú pháp inline $...$
    );

    switch (block.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: MarkdownWidget(
            data: block.data ?? '',
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            markdownGenerator: markdownConfig,
            config: MarkdownConfig(
              configs: [
                PConfig(
                  textStyle: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
