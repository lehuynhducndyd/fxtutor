import 'package:flutter/material.dart';
// Đảm bảo đường dẫn này đúng tới file latex.dart bạn đã tạo
import 'package:fx_tutor/common/latex.dart';
// --- IMPORT CÁC FILE CỦA BẠN ---
import 'package:fx_tutor/models/learning_content.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../../../common/key_mapper.dart';

class LearningDetailScreen extends StatelessWidget {
  final LearningContent content;

  const LearningDetailScreen({super.key, required this.content});

  static const String route = 'LearningDetailScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(content.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content.blocks.map((block) => _buildBlock(context, block)).toList(),
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
