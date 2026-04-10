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

  // Trạng thái lưu trữ vai trò đang được chọn để lọc
  String _selectedRoleFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    FocusScope.of(context).unfocus();
    context.read<UserManagementCubit>().loadUsers(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Quản lý Người dùng'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // ================= CHIPS PHÂN LOẠI =================
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildFilterChip('Tất cả', 'all', colorScheme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Quản trị viên', 'admin', colorScheme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cộng tác viên', 'collaborator', colorScheme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Người dùng', 'user', colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ================= DANH SÁCH NGƯỜI DÙNG =================
            Expanded(
              child: BlocBuilder<UserManagementCubit, UserManagementState>(
                builder: (context, state) {
                  if (state.status == UserListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == UserListStatus.error) {
                    return _buildErrorState(state.errorMessage, colorScheme, textTheme);
                  }

                  // Lọc danh sách theo Chip đã chọn
                  final filteredUsers = state.users.where((u) {
                    if (_selectedRoleFilter == 'all') return true;
                    return u.role == _selectedRoleFilter;
                  }).toList();

                  // Xử lý hiển thị khi rỗng (sau khi lọc)
                  if (filteredUsers.isEmpty) {
                    return _buildEmptyState(colorScheme, textTheme);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _onSearch(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final isLocked = !user.isActive;

                        return Card(
                          elevation: 0,
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

                                      // GỌI HÀM RENDER QUYỀN Ở ĐÂY
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

  // ================= CÁC WIDGET PHỤ TRỢ =================

  Widget _buildFilterChip(String label, String roleValue, ColorScheme colorScheme) {
    final isSelected = _selectedRoleFilter == roleValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRoleFilter = roleValue;
          });
        }
      },
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildRoleDropdown(
    BuildContext context,
    String currentRole,
    String userId,
    ColorScheme colorScheme,
  ) {
    // 1. Vô hiệu hóa Admin: Trả về một block tĩnh, không có dropdown
    if (currentRole == 'admin') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.error.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_rounded, size: 16, color: colorScheme.error),
            const SizedBox(width: 6),
            Text(
              'Quản trị viên',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Dành cho các vai trò khác (Có thể thay đổi)
    Color roleColor = currentRole == 'collaborator' ? Colors.green.shade600 : colorScheme.primary;

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
          items: const [
            DropdownMenuItem(
              value: 'user',
              child: Text('Người dùng'),
            ),
            DropdownMenuItem(
              value: 'collaborator',
              child: Text('Cộng tác viên'),
            ),
            // Đã xóa lựa chọn 'admin' ở đây để người khác không thể tự thăng cấp lên admin (Tùy logic của bạn)
          ],
          onChanged: (String? newValue) async {
            if (newValue != null && newValue != currentRole) {
              final success = await context.read<UserManagementCubit>().changeRole(
                userId,
                newValue,
              );

              if (success && context.mounted) {
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

  // Tách widget Empty State cho gọn code
  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
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
            "Thử tìm kiếm hoặc đổi bộ lọc xem sao.",
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  // Tách widget Error State cho gọn code
  Widget _buildErrorState(String? errorMsg, ColorScheme colorScheme, TextTheme textTheme) {
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
            errorMsg ?? "Không thể tải dữ liệu",
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
}

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
