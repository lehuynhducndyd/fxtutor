import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'contribute_cubit.dart';

class AddContributeScreen extends StatefulWidget {
  const AddContributeScreen({super.key});
  static const String route = 'AddContributeScreen';

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
    // Ẩn bàn phím khi bấm gửi
    FocusScope.of(context).unfocus();

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập nội dung đóng góp!'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Gọi Cubit để submit
    final success = await context.read<ContributeCubit>().submitContribution(content);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi đóng góp thành công! Cảm ơn bạn rất nhiều.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Trở về màn hình trước
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      // Chạm ra ngoài để ẩn bàn phím
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text(
            'Gửi đóng góp',
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= HỘP THÔNG ĐIỆP =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.primaryContainer),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chúng tôi rất trân trọng mọi ý kiến đóng góp, báo lỗi hoặc đề xuất tính năng của bạn để giúp ứng dụng ngày càng hoàn thiện hơn.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ================= KHUNG NHẬP LIỆU =================
              Text(
                "Nội dung đóng góp",
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLines: 6,
                minLines: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung chi tiết tại đây...',
                  hintStyle: TextStyle(color: colorScheme.outline),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),

              // ================= NÚT GỬI M3 =================
              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isLoading ? 'Đang gửi...' : 'Gửi đóng góp ngay',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
