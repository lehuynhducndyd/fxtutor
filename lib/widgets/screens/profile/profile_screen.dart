import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/auth/auth_cubit.dart';
import 'package:fx_tutor/widgets/screens/profile/profile_cubit.dart';

import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(context.read<AuthService>())),
        BlocProvider(create: (context) => ProfileCubit(context.read<ProfileService>())..loadUser()),
      ],
      child: Page(),
    );
  }
}

class Page extends StatefulWidget {
  const Page({
    super.key,
  });

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        var user = state.user;
        final profileCubit = context.read<ProfileCubit>();
        final nameController = TextEditingController();
        nameController.text = user.fullName ?? "";
        print(user);
        if (user.id.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          children: [
            Text("${user.email}"),
            Text("${user.role}"),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Tên hiển thị"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileCubit>().updateProfile(fullName: nameController.text);
              },
              child: Text("Cập nhật"),
            ),
            ElevatedButton(
              onPressed: profileCubit.profileService.isEmailProvider()
                  ? () {
                      _showChangePasswordDialog(context, profileCubit);
                    }
                  : null,
              child: const Text("Đổi mật khẩu"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().logout();
                Navigator.pushReplacementNamed(context, LoginScreen.route);
              },
              child: Text("Đăng xuất"),
            ),
          ],
        );
      },
    );
  }
}

void _showChangePasswordDialog(BuildContext context, ProfileCubit profileCubit) {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      String errorText = '';

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Đổi mật khẩu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới (ít nhất 6 ký tự)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newPass = newPasswordController.text.trim();
                  final confirmPass = confirmPasswordController.text.trim();

                  if (newPass.length < 6) {
                    setState(() {
                      errorText = 'Mật khẩu phải từ 6 ký tự trở lên';
                    });
                    return;
                  }

                  if (newPass != confirmPass) {
                    setState(() {
                      errorText = 'Mật khẩu xác nhận không khớp';
                    });
                    return;
                  }

                  profileCubit.changePassword(newPass);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đổi mật khẩu thành công!'),
                    ),
                  );
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    },
  );
}
