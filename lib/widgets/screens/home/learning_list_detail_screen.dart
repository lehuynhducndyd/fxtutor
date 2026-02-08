import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserModel?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "Người tạo: Đang tải...",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return Text(
                    widget.content.userId == null ? "" : "Người tạo: ${widget.content.userId}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  );
                }
                final user = snapshot.data!;
                return Row(
                  children: [
                    if (user.avatarUrl != null)
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(user.avatarUrl!),
                      )
                    else
                      const Icon(Icons.account_circle, size: 24, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Người tạo: ${user.fullName}  ${user.email}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ...widget.content.blocks.map((block) => _buildBlock(context, block)).toList(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, QuizScreen.route, arguments: widget.content);
              },
              child: Text("làm trắc nghiệm"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, ContentBlock block) {
    // Cấu hình chung cho Markdown (Text & Latex)
    final markdownConfig = MarkdownGenerator(
      generators: [latexGenerator], // Kích hoạt Latex generator
      inlineSyntaxList: [LatexSyntax()], // Kích hoạt cú pháp inline $...$
    );

    switch (block.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MarkdownWidget(
            data: block.data ?? '',
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            markdownGenerator: markdownConfig,
            config: MarkdownConfig(
              configs: [
                const PConfig(
                  textStyle: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        );

      case 'latex':
        // Với khối Latex riêng biệt, ta bao quanh bởi $$ để nó hiển thị căn giữa và to
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50], // Nền nhẹ cho công thức
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: MarkdownWidget(
            data: "\$\$${block.data}\$\$", // Ép kiểu Block Math
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            markdownGenerator: MarkdownGenerator(
              generators: [latexGenerator], // Kích hoạt Latex (file common/latex.dart)
              inlineSyntaxList: [LatexSyntax()],
            ),
          ),
        );

      case 'image':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                    minWidth: double.infinity,
                  ),
                  color: Colors.grey[50],
                  child: Image.network(
                    block.url ?? '',
                    fit: BoxFit.contain,
                    // Loading builder
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    // Error builder
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          Text("Không tải được ảnh", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (block.caption != null && block.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    block.caption!,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      case '580keylog':
        var text = KeyMapper.convert(block.data ?? '');
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Casio580',
              fontSize: 24,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: text),
            ],
          ),
        );
      case '880keylog':
        var text = KeyMapper.convert(block.data ?? '');
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Casio880',
              fontSize: 24,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: text),
            ],
          ),
        );
      //case '880keylog':
      // Đã loại bỏ Video theo yêu cầu trước đó, nhưng nếu data cũ còn thì ẩn đi hoặc hiện placeholder
      default:
        return const SizedBox.shrink();
    }
  }
}
