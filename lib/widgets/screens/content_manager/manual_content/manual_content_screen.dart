import 'package:flutter/material.dart';

class ManualContentScreen extends StatefulWidget {
  const ManualContentScreen({super.key});

  static const String route = 'ManualContentScreen';

  @override
  State<ManualContentScreen> createState() => _ManualContentScreenState();
}

class _ManualContentScreenState extends State<ManualContentScreen> {
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
        title: const Text("Nội dung hướng dẫn"), // Phù hợp với Manual Content
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
    return const Center(
      child: Text("Danh sách nội dung hướng dẫn sử dụng"),
    );
  }
}
