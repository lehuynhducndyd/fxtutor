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
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt yêu cầu Cộng tác viên')),
      body: BlocBuilder<AdminCollaboratorCubit, AdminCollaboratorState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text('Lỗi: ${state.error}'));
          if (state.requests.isEmpty)
            return const Center(child: Text('Không có yêu cầu nào đang chờ duyệt.'));

          return ListView.builder(
            itemCount: state.requests.length,
            itemBuilder: (context, index) {
              final req = state.requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(req.userEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Gửi lúc: ${req.createdAt.toString().substring(0, 16)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút Từ chối
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _handle(context, req.id, req.userId, false),
                      ),
                      // Nút Duyệt
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _handle(context, req.id, req.userId, true),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handle(BuildContext context, String reqId, String targetUserId, bool isApproved) async {
    final actionName = isApproved ? 'Duyệt' : 'Từ chối';
    final success = await context.read<AdminCollaboratorCubit>().handleRequest(
      reqId,
      targetUserId,
      isApproved,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã $actionName thành công!')));
    }
  }
}
