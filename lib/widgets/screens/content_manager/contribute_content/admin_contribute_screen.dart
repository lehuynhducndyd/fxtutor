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
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Đóng góp')),
      body: BlocBuilder<AdminContributeCubit, AdminContributeState>(
        builder: (context, state) {
          if (state.loadStatus == AdminContributeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.loadStatus == AdminContributeStatus.error) {
            return Center(child: Text("Lỗi: ${state.errorMessage}"));
          }

          if (state.contributions.isEmpty) {
            return const Center(child: Text("Chưa có đóng góp nào cần duyệt."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.contributions.length,
            itemBuilder: (context, index) {
              final item = state.contributions[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.userEmail,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(item.status),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        item.content,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gửi lúc: ${item.createdAt.toString().substring(0, 16)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (item.response != null && item.response!.isNotEmpty) ...[
                        const Divider(),
                        Text(
                          "Phản hồi: ${item.response}",
                          style: const TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                  // Bấm vào để mở hộp thoại duyệt
                  onTap: () =>
                      _showReviewDialog(context, item, context.read<AdminContributeCubit>()),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hộp thoại để Admin xử lý
  void _showReviewDialog(
    BuildContext context,
    AdminContributeModel item,
    AdminContributeCubit cubit,
  ) {
    final responseController = TextEditingController(text: item.response ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kiểm duyệt đóng góp'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nội dung: ${item.content}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: responseController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Lời phản hồi cho User',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final success = await cubit.review(
                      item.id,
                      'rejected',
                      responseController.text.trim(),
                    );
                    if (success && context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Đã từ chối')));
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Từ chối'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final success = await cubit.review(
                      item.id,
                      'approved',
                      responseController.text.trim(),
                    );
                    if (success && context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Đã duyệt')));
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Duyệt'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Đã duyệt';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Từ chối';
        break;
      default:
        color = Colors.orange;
        text = 'Chờ duyệt';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
