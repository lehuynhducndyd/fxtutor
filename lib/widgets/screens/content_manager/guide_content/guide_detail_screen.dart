import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';
import 'package:fx_tutor/models/user_model.dart';
import 'package:fx_tutor/services/profile_service.dart';
import 'package:markdown_widget/markdown_widget.dart';

class GuideDetailScreen extends StatelessWidget {
  final CalculatorGuideModel guide;

  const GuideDetailScreen({super.key, required this.guide});

  static const String route = 'GuideDetailScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guide.actionName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreatorInfo(context),
            const SizedBox(height: 16),
            if (guide.compatibleModels.isNotEmpty) ...[
              const Text(
                "Dòng máy tương thích:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: guide.compatibleModels
                    .map(
                      (model) => Chip(
                        label: Text(model),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    )
                    .toList(),
              ),
              const Divider(height: 32),
            ],
            ...guide.methods.map((method) => _buildMethodSection(context, method)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorInfo(BuildContext context) {
    if (guide.userId == null || guide.userId!.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<UserModel?>(
      future: context.read<ProfileService>().getProfileById(guide.userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "Người tạo: ${user.fullName ?? 'Ẩn danh'}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMethodSection(BuildContext context, GuideMethod method) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (method.methodName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              method.methodName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        MarkdownWidget(
          data: method.content,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          config: MarkdownConfig(
            configs: [
              const PConfig(
                textStyle: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
