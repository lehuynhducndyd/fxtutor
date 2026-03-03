import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/collaborator_service.dart';
import 'admin_collaborator_cubit.dart';

class AdminCollaboratorScreen extends StatelessWidget {
  const AdminCollaboratorScreen({super.key});
  static const String route = 'AdminCollaboratorScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCollaboratorCubit(CollaboratorService())..loadRequests(),
      child: const AdminCollaboratorView(),
    );
  }
}

class AdminCollaboratorView extends StatelessWidget {
  const AdminCollaboratorView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Duyệt Yêu cầu Cộng tác', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<AdminCollaboratorCubit, AdminCollaboratorState>(
        builder: (context, state) {
          // ================= TRẠNG THÁI LOADING =================
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ================= TRẠNG THÁI LỖI =================
          if (state.error != null) {
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
                  Text(state.error!, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => context.read<AdminCollaboratorCubit>().loadRequests(),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          // ================= TRẠNG THÁI TRỐNG =================
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_reg_rounded, size: 80, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    "Không có yêu cầu nào",
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hiện tại chưa có yêu cầu cộng tác nào cần duyệt.",
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ],
              ),
            );
          }

          // ================= DANH SÁCH YÊU CẦU =================
          return RefreshIndicator(
            onRefresh: () async => context.read<AdminCollaboratorCubit>().loadRequests(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = state.requests[index];

                return Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thông tin người gửi
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.person_rounded, color: colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.userEmail,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: colorScheme.outline,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        req.createdAt.toString().substring(0, 16),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Hai nút hành động To/Rõ ràng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showConfirmDialog(context, req, false),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text("Từ chối"),
                              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () => _showConfirmDialog(context, req, true),
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text("Phê duyệt"),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // Hộp thoại xác nhận thao tác an toàn
  void _showConfirmDialog(BuildContext context, dynamic req, bool isApprove) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionText = isApprove ? "phê duyệt" : "từ chối";
    final titleIcon = isApprove ? Icons.check_circle_rounded : Icons.warning_amber_rounded;
    final titleColor = isApprove ? Colors.green.shade600 : colorScheme.error;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(titleIcon, color: titleColor),
            const SizedBox(width: 8),
            Text(isApprove ? "Xác nhận phê duyệt" : "Xác nhận từ chối"),
          ],
        ),
        content: Text(
          "Bạn có chắc chắn muốn $actionText yêu cầu cộng tác của tài khoản '${req.userEmail}' không?",
          style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Hủy", style: TextStyle(color: colorScheme.outline)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Đóng dialog
              _handle(context, req.id, req.userId, isApprove); // Gọi hàm xử lý
            },
            style: FilledButton.styleFrom(
              backgroundColor: titleColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? "PHÊ DUYỆT" : "TỪ CHỐI"),
          ),
        ],
      ),
    );
  }

  // Xử lý gửi request và hiện thông báo
  void _handle(BuildContext context, String reqId, String targetUserId, bool isApproved) async {
    final actionName = isApproved ? 'Phê duyệt' : 'Từ chối';

    final success = await context.read<AdminCollaboratorCubit>().handleRequest(
      reqId,
      targetUserId,
      isApproved,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isApproved ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text('Đã $actionName thành công!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: isApproved ? Colors.green.shade700 : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
