import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/admin_contribute_model.dart';
import '../../../../services/admin_contribute_service.dart';
import 'admin_contribute_cubit.dart';

class AdminContributeScreen extends StatelessWidget {
  static const String route = 'AdminContributeScreen';

  const AdminContributeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminContributeCubit(AdminContributeService())..loadAllContributions(),
      child: const AdminContributeView(),
    );
  }
}

class AdminContributeView extends StatelessWidget {
  const AdminContributeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Kiểm duyệt Đóng góp', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<AdminContributeCubit, AdminContributeState>(
        builder: (context, state) {
          // ================= TRẠNG THÁI LOADING =================
          if (state.loadStatus == AdminContributeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ================= TRẠNG THÁI LỖI =================
          if (state.loadStatus == AdminContributeStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    "Đã có lỗi xảy ra",
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? "Không thể tải dữ liệu",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => context.read<AdminContributeCubit>().loadAllContributions(),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          // ================= TRẠNG THÁI TRỐNG =================
          if (state.contributions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 80, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    "Hộp thư trống",
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Chưa có đóng góp nào cần duyệt lúc này.",
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ],
              ),
            );
          }

          // ================= DANH SÁCH ĐÓNG GÓP =================
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminContributeCubit>().loadAllContributions();
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.contributions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.contributions[index];

                return Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        _showReviewDialog(context, item, context.read<AdminContributeCubit>()),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Email & Trạng thái
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: colorScheme.primaryContainer,
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.userEmail,
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(item.status),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // Nội dung đóng góp
                          Text(
                            item.content,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Footer: Thời gian
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: colorScheme.outline),
                              const SizedBox(width: 6),
                              Text(
                                item.createdAt.toString().substring(0, 16),
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          // Phản hồi của Admin (Nếu có)
                          if (item.response != null && item.response!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.secondaryContainer),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings_rounded,
                                        size: 16,
                                        color: colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Phản hồi đã gửi:",
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.response!,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Hộp thoại kiểm duyệt M3
  void _showReviewDialog(
    BuildContext context,
    AdminContributeModel item,
    AdminContributeCubit cubit,
  ) {
    final responseController = TextEditingController(text: item.response ?? '');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.gavel_rounded, color: colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Kiểm duyệt đóng góp'),
            ],
          ),
          content: SingleChildScrollView(
            // Tránh lỗi overflow khi mở bàn phím
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.content,
                      style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Lời phản hồi cho người dùng",
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: responseController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhập phản hồi hoặc lý do từ chối...',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Hủy', style: TextStyle(color: colorScheme.outline)),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
              ),
              onPressed: () async {
                final success = await cubit.review(
                  item.id,
                  'rejected',
                  responseController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(dialogContext); // Đóng dialog
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã từ chối đóng góp')),
                    );
                  }
                }
              },
              child: const Text('Từ chối'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final success = await cubit.review(
                  item.id,
                  'approved',
                  responseController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(dialogContext); // Đóng dialog
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã duyệt thành công')),
                    );
                  }
                }
              },
              child: const Text('Duyệt'),
            ),
          ],
        );
      },
    );
  }

  // Hàm tạo badge trạng thái chuẩn M3
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Đã duyệt';
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Từ chối';
        icon = Icons.cancel_rounded;
        break;
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        text = 'Chờ duyệt';
        icon = Icons.pending_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
