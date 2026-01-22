import 'package:flutter/material.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';
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
