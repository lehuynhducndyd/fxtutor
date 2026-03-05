import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';
import 'package:fx_tutor/models/user_model.dart';
import 'package:fx_tutor/services/profile_service.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';

class GuideDetailScreen extends StatefulWidget {
  final CalculatorGuideModel guide;

  const GuideDetailScreen({super.key, required this.guide});

  static const String route = 'GuideDetailScreen';

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Future 1 lần duy nhất để tối ưu hiệu năng
    if (widget.guide.userId != null && widget.guide.userId!.isNotEmpty) {
      _userFuture = context.read<ProfileService>().getProfileById(widget.guide.userId!);
    } else {
      _userFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.guide.actionName,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER: THÔNG TIN TÁC GIẢ =================
            _buildCreatorInfo(context),
            const SizedBox(height: 24),

            // ================= DÒNG MÁY TƯƠNG THÍCH =================
            if (widget.guide.compatibleModels.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.devices_rounded, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Dòng máy hỗ trợ",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.guide.compatibleModels.map((model) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20), // Bo tròn dạng viên thuốc (Pill)
                      border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Text(
                      model,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
            ],

            // ================= CÁC PHƯƠNG THỨC (CÁCH GIẢI) =================
            ...widget.guide.methods.map((method) => _buildMethodSection(context, method)),

            const SizedBox(height: 40), // Căn lề dưới đáy cho thoáng
          ],
        ),
      ),
    );
  }

  // Widget Thẻ Tác giả M3
  Widget _buildCreatorInfo(BuildContext context) {
    if (widget.guide.userId == null || widget.guide.userId!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        String authorName = "Ẩn danh";
        String authorEmail = "Chưa rõ email";

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          authorName = user.fullName ?? "Người dùng";
          authorEmail = user.email ?? "";
        } else {
          authorName = widget.guide.userId!; // Hiển thị ID nếu không tải được profile
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
    );
  }

  // Widget hiển thị từng Phương thức (Cách giải)
  Widget _buildMethodSection(BuildContext context, GuideMethod method) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề Cách giải
          if (method.methodName.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 20, color: colorScheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      method.methodName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Nội dung Markdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownWidget(
              data: method.content,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              config: MarkdownConfig(
                configs: [
                  PConfig(
                    textStyle: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyLarge?.color, // Hỗ trợ Dark Mode
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
}
