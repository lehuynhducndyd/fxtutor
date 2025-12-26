import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/enum/drawer_item.dart';
import '../../../main_cubit.dart';

class MenuScreen extends StatelessWidget {
  static const String route = 'MenuScreen';

  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ListView để đảm bảo scroll được nếu màn hình nhỏ
    return Drawer(
      child: Column(
        children: [
          // 1. HEADER: Phần thông tin người dùng
          _buildHeader(context),

          // 2. BODY: Danh sách Menu
          Expanded(
            child: BlocBuilder<MainCubit, MainState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  children: [
                    _buildMenuItem(
                      context: context,
                      label: "Học tập",
                      icon: Icons.school_outlined,
                      selectedIcon: Icons.school,
                      isSelected: state.selected == DrawerItem.Home,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.Home);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Tính toán khác",
                      icon: Icons.calculate_outlined,
                      selectedIcon: Icons.calculate_outlined,
                      isSelected: state.selected == DrawerItem.Calculate,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.Calculate);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Đóng góp",
                      icon: Icons.add_box_outlined,
                      selectedIcon: Icons.add_box,
                      isSelected: state.selected == DrawerItem.Contribute,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.Contribute);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Cài đặt",
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      isSelected: state.selected == DrawerItem.Setting,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.Setting);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Hồ sơ",
                      icon: Icons.account_circle_outlined,
                      selectedIcon: Icons.account_circle,
                      isSelected: state.selected == DrawerItem.Profile,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.Profile);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Thông tin ứng dụng",
                      icon: Icons.info_outline,
                      selectedIcon: Icons.info,
                      isSelected: state.selected == DrawerItem.Info,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.Info);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Hướng dẫn sử dụng",
                      icon: Icons.question_mark_outlined,
                      selectedIcon: Icons.question_mark,
                      isSelected: state.selected == DrawerItem.Manual,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.Manual);
                        Navigator.pop(context);
                      },
                    ),
                    Divider(),
                    //const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Quản lý nội dung",
                      icon: Icons.folder_copy_outlined,
                      selectedIcon: Icons.folder_copy,
                      isSelected: state.selected == DrawerItem.ContentManager,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.ContentManager);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8), // Khoảng cách giữa các nút
                    _buildMenuItem(
                      context: context,
                      label: "Quản lý người dùng",
                      icon: Icons.manage_accounts_outlined,
                      selectedIcon: Icons.manage_accounts,
                      isSelected: state.selected == DrawerItem.UserManager,
                      onTap: () {
                        context.read<MainCubit>().setSelected(DrawerItem.UserManager);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Header đẹp mắt
  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer, // Lấy màu từ Theme
        // Có thể thêm ảnh nền: image: DecorationImage(...)
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Text(
          "A", // Chữ cái đầu của tên user
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      accountName: Text(
        "Người dùng",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      accountEmail: Text(
        "user@example.com",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
        ),
      ),
    );
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
      // Bo tròn góc nút bấm (Style M3)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),

      // Màu nền khi được chọn
      tileColor: isSelected ? colorScheme.secondaryContainer : null,

      // Icon phía trước (thay đổi khi chọn/không chọn)
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
      ),

      // Tiêu đề
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
        ),
      ),

      // Mũi tên bên phải (Logic cũ của bạn, nhưng làm mờ đi cho tinh tế)
      trailing: !isSelected
          ? Icon(Icons.navigate_next, size: 20, color: colorScheme.outline)
          : null,

      onTap: onTap,
    );
  }
}
