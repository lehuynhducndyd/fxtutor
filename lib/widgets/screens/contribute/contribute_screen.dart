import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/contribute_service.dart';
import 'add_contribute_screen.dart';
import 'contribute_cubit.dart';

class ContributeScreen extends StatelessWidget {
  static const String route = 'ContributeScreen';

  const ContributeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bọc BlocProvider ở ngoài cùng để khởi tạo Cubit
    return BlocProvider(
      create: (context) => ContributeCubit(ContributeService())..loadContributions(),
      child: const ContributeView(),
    );
  }
}

class ContributeView extends StatelessWidget {
  const ContributeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Lịch sử đóng góp',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<ContributeCubit, ContributeState>(
        builder: (context, state) {
          // ================= 1. TRẠNG THÁI LOADING =================
          if (state.loadStatus == ContributeLoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ================= 2. TRẠNG THÁI LỖI =================
          if (state.loadStatus == ContributeLoadStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    "Có lỗi xảy ra",
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? "Không thể tải dữ liệu",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => context.read<ContributeCubit>().loadContributions(),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          // ================= 3. TRẠNG THÁI TRỐNG =================
          if (state.contributions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism_outlined, size: 80, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    "Bạn chưa có đóng góp nào",
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hãy gửi ý kiến để giúp ứng dụng tốt hơn nhé!",
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ],
              ),
            );
          }

          // ================= 4. DANH SÁCH ĐÓNG GÓP =================
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ContributeCubit>().loadContributions();
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Thời gian & Trạng thái
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  size: 14,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.createdAt.toString().substring(0, 16),
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusBadge(item.status),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Nội dung đóng góp của User
                        Text(
                          item.content,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),

                        // Phản hồi từ Admin (Nếu có)
                        if (item.response != null && item.response!.isNotEmpty) ...[
                          const SizedBox(height: 16),
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
                                    Text(
                                      "Phản hồi từ Admin:",
                                      style: textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
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
                );
              },
            ),
          );
        },
      ),

      // ================= FLOATING ACTION BUTTON =================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Chuyển sang trang thêm đóng góp, mang theo Cubit hiện tại
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ContributeCubit>(),
                child: const AddContributeScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Gửi đóng góp', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
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
