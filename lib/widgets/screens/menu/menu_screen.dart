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
    // Sử dụng ListView để đảm bảo scroll được nếu màn hình nhỏ
    return Drawer(
      child: SafeArea(
        child: BlocProvider(
          create: (context) => ProfileCubit(context.read<ProfileService>())..loadUser(),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<MainCubit, MainState>(
                  builder: (context, state) {
                    return BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        var user = context.read<ProfileCubit>().state.user;
                        var userRole = user.role;
                        if (userRole.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!user.isActive) {
                          return ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                            children: [
                              Text(
                                "Tài khoản của bạn đã bị khóa",
                              ),
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
                                isSelected: state.selected == DrawerItem.Guide,
                                onTap: () {
                                  context.read<MainCubit>().setSelected(DrawerItem.Guide);
                                  Navigator.pop(context);
                                },
                              ),
                              Divider(),
                              //const SizedBox(height: 8), // Khoảng cách giữa các nút
                            ],
                          );
                        }
                        if (userRole == "user") {
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
                                isSelected: state.selected == DrawerItem.Guide,
                                onTap: () {
                                  context.read<MainCubit>().setSelected(DrawerItem.Guide);
                                  Navigator.pop(context);
                                },
                              ),
                              Divider(),
                              //const SizedBox(height: 8), // Khoảng cách giữa các nút
                            ],
                          );
                        }
                        if (userRole == "collaborator") {
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
                                isSelected: state.selected == DrawerItem.Guide,
                                onTap: () {
                                  context.read<MainCubit>().setSelected(DrawerItem.Guide);
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
                            ],
                          );
                        } else {
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
                                isSelected: state.selected == DrawerItem.Guide,
                                onTap: () {
                                  context.read<MainCubit>().setSelected(DrawerItem.Guide);
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
                        }
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
