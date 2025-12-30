import 'package:flutter/material.dart';

class LearningContentScreen extends StatefulWidget {
  const LearningContentScreen({super.key});
  static const String route = 'LearningContentScreen'; // Cập nhật route nếu cần

  @override
  State<LearningContentScreen> createState() => _LearningContentScreenState();
}

class _LearningContentScreenState extends State<LearningContentScreen> {
  @override
  Widget build(BuildContext context) {
    return const Page();
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nội dung học tập"), // Đổi tiêu đề cho khớp tên file
      ),
      body: const Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Danh sách nội dung học tập"));
  }
}
