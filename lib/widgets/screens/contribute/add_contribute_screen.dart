import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'contribute_cubit.dart';

class AddContributeScreen extends StatefulWidget {
  const AddContributeScreen({super.key});

  @override
  State<AddContributeScreen> createState() => _AddContributeScreenState();
}

class _AddContributeScreenState extends State<AddContributeScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đóng góp!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Gọi Cubit để submit
    final success = await context.read<ContributeCubit>().submitContribution(content);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đóng góp thành công!')),
      );
      Navigator.pop(context); // Trở về màn hình trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm đóng góp mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chúng tôi rất trân trọng mọi ý kiến đóng góp của bạn để cải thiện ứng dụng.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung đóng góp, báo lỗi, hoặc đề xuất tính năng...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Gửi ngay',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
