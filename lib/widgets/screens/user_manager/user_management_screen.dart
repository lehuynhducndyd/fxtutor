import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/user_management_service.dart';
import 'user_management_cubit.dart';

class UserManagementScreen extends StatelessWidget {
  static const String route = 'UserManagementScreen';

  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserManagementCubit(UserManagementService())..loadUsers(),
      child: const UserManagementView(),
    );
  }
}

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    // Gọi Cubit để load lại list với từ khóa tìm kiếm
    context.read<UserManagementCubit>().loadUsers(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Người dùng')),
      body: Column(
        children: [
          // ================= 1. THANH TÌM KIẾM =================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo email hoặc tên...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _onSearch,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _onSearch(), // Hỗ trợ bấm Enter trên bàn phím
            ),
          ),

          // ================= 2. DANH SÁCH NGƯỜI DÙNG =================
          Expanded(
            child: BlocBuilder<UserManagementCubit, UserManagementState>(
              builder: (context, state) {
                if (state.status == UserListStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == UserListStatus.error) {
                  return Center(
                    child: Text(
                      "Lỗi: ${state.errorMessage}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state.users.isEmpty) {
                  return const Center(child: Text("Không tìm thấy người dùng nào."));
                }

                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // Đổi màu nền xám nhẹ nếu tài khoản bị khóa để dễ nhận biết
                      color: user.isActive ? Colors.white : Colors.grey.shade200,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.isActive
                              ? Colors.blue.shade100
                              : Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            color: user.isActive ? Colors.blue : Colors.grey,
                          ),
                        ),
                        title: Text(
                          user.fullName ?? 'Chưa cập nhật tên',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: user.isActive
                                ? TextDecoration.none
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        //subtitle: Text(user.email),

                        // ================= 3. KHU VỰC NÚT BẤM (PHÂN QUYỀN & KHÓA) =================
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 3.1 Dropdown phân quyền
                                DropdownButton<String>(
                                  value: user.role,
                                  underline: const SizedBox(), // Ẩn gạch chân
                                  items: const [
                                    DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                                    DropdownMenuItem(
                                      value: 'collaborator',
                                      child: Text('CTV'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'admin',
                                      child: Text('Admin', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                  onChanged: (String? newValue) async {
                                    if (newValue != null && newValue != user.role) {
                                      final success = await context
                                          .read<UserManagementCubit>()
                                          .changeRole(user.id, newValue);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Đã đổi quyền thành ${toRole(newValue)}'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),

                                const SizedBox(width: 8), // Khoảng cách giữa 2 nút
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String toRole(String s) {
  switch (s) {
    case 'user':
      return 'Người dùng';
    case 'collaborator':
      return 'CTV';
    case 'admin':
      return 'Admin';
    default:
      return 'Người dùng';
  }
}
