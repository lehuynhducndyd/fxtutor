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
    FocusScope.of(context).unfocus(); // Ẩn bàn phím khi bấm tìm kiếm
    context.read<UserManagementCubit>().loadUsers(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Chạm ra ngoài để ẩn bàn phím
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Quản lý Người dùng', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            // ================= THANH TÌM KIẾM M3 =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Tìm theo email hoặc tên...',
                  prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: colorScheme.onPrimary, size: 20),
                      onPressed: _onSearch,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onSubmitted: (_) => _onSearch(),
              ),
            ),

            // ================= DANH SÁCH NGƯỜI DÙNG =================
            Expanded(
              child: BlocBuilder<UserManagementCubit, UserManagementState>(
                builder: (context, state) {
                  // Trạng thái Loading
                  if (state.status == UserListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Trạng thái Lỗi
                  if (state.status == UserListStatus.error) {
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
                            onPressed: _onSearch,
                            child: const Text("Thử lại"),
                          ),
                        ],
                      ),
                    );
                  }

                  // Trạng thái Trống
                  if (state.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off_rounded, size: 80, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            "Không tìm thấy ai",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Thử tìm kiếm với một từ khóa khác xem sao.",
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    );
                  }

                  // Danh sách hiển thị
                  return RefreshIndicator(
                    onRefresh: () async => _onSearch(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: state.users.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        final isLocked = !user.isActive;

                        return Card(
                          elevation: 0,
                          // Nền đỏ nhạt nếu bị khóa, nền xám nhạt nếu bình thường
                          color: isLocked
                              ? colorScheme.errorContainer.withOpacity(0.3)
                              : colorScheme.surfaceContainerHighest.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isLocked
                                  ? colorScheme.error.withOpacity(0.3)
                                  : colorScheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isLocked
                                      ? colorScheme.errorContainer
                                      : colorScheme.primaryContainer,
                                  child: Icon(
                                    isLocked ? Icons.lock_person_rounded : Icons.person_rounded,
                                    color: isLocked ? colorScheme.error : colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Thông tin Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user.fullName ?? 'Chưa cập nhật tên',
                                              style: textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isLocked
                                                    ? colorScheme.onSurfaceVariant
                                                    : colorScheme.onSurface,
                                                decoration: isLocked
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isLocked)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.error,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "Đã khóa",
                                                style: TextStyle(
                                                  color: colorScheme.onError,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // KHU VỰC CHỌN QUYỀN (ROLE DROPDOWN TÙY CHỈNH)
                                      _buildRoleDropdown(context, user.role, user.id, colorScheme),
                                    ],
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  // Giao diện thẻ Dropdown phân quyền xịn xò M3
  Widget _buildRoleDropdown(
    BuildContext context,
    String currentRole,
    String userId,
    ColorScheme colorScheme,
  ) {
    Color roleColor = colorScheme.primary;
    // switch (currentRole) {
    //   case 'admin':
    //     roleColor = colorScheme.error; // Đỏ cho Admin
    //     break;
    //   case 'collaborator':
    //     roleColor = Colors.green.shade600; // Xanh lá cho CTV
    //     break;
    //   default:
    //     roleColor = colorScheme.primary; // Xanh dương cho User
    // }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: roleColor.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down_rounded, color: roleColor),
          style: TextStyle(
            color: roleColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          dropdownColor: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          items: [
            DropdownMenuItem(
              value: 'user',
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Text('Người dùng'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'collaborator',
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Text('Cộng tác viên'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Text('Quản trị viên'),
                ],
              ),
            ),
          ],
          onChanged: (String? newValue) async {
            if (newValue != null && newValue != currentRole) {
              final success = await context.read<UserManagementCubit>().changeRole(
                userId,
                newValue,
              );

              if (success && context.mounted) {
                // Hiển thị thông báo mượt mà
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Đã đổi quyền thành ${toRole(newValue)}'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

// Giữ nguyên hàm Helper của bạn
String toRole(String s) {
  switch (s) {
    case 'user':
      return 'Người dùng';
    case 'collaborator':
      return 'Cộng tác viên';
    case 'admin':
      return 'Quản trị viên';
    default:
      return 'Người dùng';
  }
}
