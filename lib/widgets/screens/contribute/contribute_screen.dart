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
      // Lưu ý: Nếu bạn có truyền Service từ provider tổng thì xài context.read<ContributeService>() nha
      child: const ContributeView(),
    );
  }
}

// Tách phần giao diện ra một Widget riêng để BuildContext bên trong nhận diện được Cubit
class ContributeView extends StatelessWidget {
  const ContributeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đóng góp')),
      body: BlocBuilder<ContributeCubit, ContributeState>(
        builder: (context, state) {
          if (state.loadStatus == ContributeLoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.loadStatus == ContributeLoadStatus.error) {
            return Center(child: Text("Có lỗi xảy ra: ${state.errorMessage}"));
          }

          if (state.contributions.isEmpty) {
            return const Center(child: Text("Bạn chưa có đóng góp nào."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.contributions.length,
            itemBuilder: (context, index) {
              final item = state.contributions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.createdAt.toString().substring(0, 16),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          _buildStatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item.content, style: const TextStyle(fontSize: 16)),
                      if (item.response != null && item.response!.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text(
                          "Phản hồi từ Admin:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(item.response!, style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
        icon: const Icon(Icons.add),
        label: const Text('Gửi đóng góp'),
      ),
    );
  }

  // Hàm tạo badge trạng thái
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
