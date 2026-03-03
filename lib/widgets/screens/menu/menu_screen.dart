import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/profile/profile_cubit.dart';

import '../../../common/enum/drawer_item.dart';
import '../../../main_cubit.dart';
import '../../../services/profile_service.dart';

class MenuScreen extends StatelessWidget {
  static const String route = 'MenuScreen';

  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: BlocProvider(
          create: (context) => ProfileCubit(context.read<ProfileService>())..loadUser(),
          child: Column(
            children: [
              // ================= HEADER M3 (LOGO / TÊN APP) =================
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Icon(Icons.calculate_rounded, size: 32, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      "FX Tutor",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(indent: 16, endIndent: 16),

              // ================= DANH SÁCH MENU =================
              Expanded(
                child: BlocBuilder<MainCubit, MainState>(
                  builder: (context, mainState) {
                    return BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        var user = context.read<ProfileCubit>().state.user;
                        var userRole = user.role ?? "";

                        // Đang tải dữ liệu
                        if (userRole.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Danh sách chứa các Menu Item
                        List<Widget> menuItems = [];

                        // 1. CẢNH BÁO NẾU TÀI KHOẢN BỊ KHÓA
                        if (!user.isActive) {
                          menuItems.add(
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lock_person_rounded, color: colorScheme.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Tài khoản của bạn đã bị khóa!",
                                      style: TextStyle(
                                        color: colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // 2. CÁC MENU CƠ BẢN (Ai cũng thấy)
                        menuItems.addAll([
                          _buildMenuItem(
                            context: context,
                            label: "Học tập",
                            icon: Icons.school_outlined,
                            selectedIcon: Icons.school,
                            isSelected: mainState.selected == DrawerItem.Home,
                            onTap: () => _onMenuTap(context, DrawerItem.Home),
                          ),
                          _buildMenuItem(
                            context: context,
                            label: "Đóng góp",
                            icon: Icons.add_box_outlined,
                            selectedIcon: Icons.add_box,
                            isSelected: mainState.selected == DrawerItem.Contribute,
                            onTap: () => _onMenuTap(context, DrawerItem.Contribute),
                          ),
                          _buildMenuItem(
                            context: context,
                            label: "Cài đặt",
                            icon: Icons.settings_outlined,
                            selectedIcon: Icons.settings,
                            isSelected: mainState.selected == DrawerItem.Setting,
                            onTap: () => _onMenuTap(context, DrawerItem.Setting),
                          ),
                          _buildMenuItem(
                            context: context,
                            label: "Hồ sơ",
                            icon: Icons.account_circle_outlined,
                            selectedIcon: Icons.account_circle,
                            isSelected: mainState.selected == DrawerItem.Profile,
                            onTap: () => _onMenuTap(context, DrawerItem.Profile),
                          ),
                          _buildMenuItem(
                            context: context,
                            label: "Thông tin ứng dụng",
                            icon: Icons.info_outline,
                            selectedIcon: Icons.info,
                            isSelected: mainState.selected == DrawerItem.Info,
                            onTap: () => _onMenuTap(context, DrawerItem.Info),
                          ),
                          _buildMenuItem(
                            context: context,
                            label: "Hướng dẫn sử dụng",
                            icon: Icons.question_mark_outlined,
                            selectedIcon: Icons.question_mark,
                            isSelected: mainState.selected == DrawerItem.Guide,
                            onTap: () => _onMenuTap(context, DrawerItem.Guide),
                          ),
                        ]);

                        // 3. CÁC MENU QUẢN LÝ (Dành cho Role đặc biệt & Tài khoản chưa bị khóa)
                        if (user.isActive && userRole != "user") {
                          menuItems.add(
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(indent: 16, endIndent: 16),
                            ),
                          );

                          // Collaborator & Admin đều có Quản lý nội dung
                          if (userRole == "collaborator" || userRole == "admin") {
                            menuItems.add(
                              _buildMenuItem(
                                context: context,
                                label: "Quản lý nội dung",
                                icon: Icons.folder_copy_outlined,
                                selectedIcon: Icons.folder_copy,
                                isSelected: mainState.selected == DrawerItem.ContentManager,
                                onTap: () => _onMenuTap(context, DrawerItem.ContentManager),
                              ),
                            );
                          }

                          // Chỉ Admin mới có Quản lý người dùng
                          if (userRole == "admin") {
                            menuItems.add(
                              _buildMenuItem(
                                context: context,
                                label: "Quản lý người dùng",
                                icon: Icons.manage_accounts_outlined,
                                selectedIcon: Icons.manage_accounts,
                                isSelected: mainState.selected == DrawerItem.UserManager,
                                onTap: () => _onMenuTap(context, DrawerItem.UserManager),
                              ),
                            );
                          }
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: menuItems.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 4), // Khoảng cách đều nhau
                          itemBuilder: (context, index) => menuItems[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm helper xử lý Tap để code gọn hơn
  void _onMenuTap(BuildContext context, DrawerItem item) {
    context.read<MainCubit>().setSelected(item);
    Navigator.pop(context); // Đóng Drawer
  }

  // Widget Item được Custom theo chuẩn Material 3
  Widget _buildMenuItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      // Bo tròn góc nút bấm (Style M3 - Stadium border)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

      // Màu nền khi được chọn
      tileColor: isSelected ? colorScheme.secondaryContainer : null,

      // Icon phía trước
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
      ),

      // Tiêu đề
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
        ),
      ),

      // Mũi tên bên phải (ẩn đi khi đang chọn cho thanh lịch)
      trailing: !isSelected
          ? Icon(Icons.navigate_next_rounded, size: 20, color: colorScheme.outline.withOpacity(0.5))
          : null,

      onTap: onTap,
    );
  }
}
