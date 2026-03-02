import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/auth/auth_cubit.dart';
import 'package:fx_tutor/widgets/screens/profile/profile_cubit.dart';

import '../../../services/auth_service.dart';
import '../../../services/collaborator_service.dart';
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
      child: const Page(),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  late TextEditingController nameController;

  // Các biến để quản lý việc gọi Service trực tiếp
  String? collabStatus; // Trạng thái: pending, approved, rejected, hoặc null (chưa gửi)
  bool isLoadingCollab = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    _checkCollabStatus(); // Gọi kiểm tra trạng thái cộng tác viên ngay khi mở trang
  }

  @override
  void dispose() {
    nameController.dispose(); // Hủy controller để tránh tràn bộ nhớ
    super.dispose();
  }

  // Hàm gọi trực tiếp Service để lấy trạng thái
  Future<void> _checkCollabStatus() async {
    try {
      final req = await CollaboratorService().getMyRequestStatus();
      if (mounted) {
        setState(() {
          collabStatus = req?.status;
          isLoadingCollab = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingCollab = false);
    }
  }

  // Hàm gửi yêu cầu trực tiếp
  Future<void> _sendCollabRequest() async {
    try {
      await CollaboratorService().requestToCollaborate();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu thành công!')));
        // Gửi xong thì load lại trạng thái để ẩn nút đi, hiện chữ "Đang chờ duyệt"
        setState(() => isLoadingCollab = true);
        await _checkCollabStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // Cập nhật text cho controller 1 lần duy nhất khi dữ liệu user load xong
        if (state.user.id.isNotEmpty && nameController.text.isEmpty) {
          nameController.text = state.user.fullName ?? "";
        }
      },
      builder: (context, state) {
        var user = state.user;
        final profileCubit = context.read<ProfileCubit>();

        if (user.id.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          // Đổi thành ListView để tránh lỗi tràn màn hình nếu nội dung dài
          padding: const EdgeInsets.all(16.0),
          children: [
            Text("Email: ${user.email}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Vai trò: ${user.role?.toUpperCase()}"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Tên hiển thị"),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileCubit>().updateProfile(fullName: nameController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đổi tên thành công!')),
                    );
                  },
                  child: const Text("Cập nhật tên"),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: profileCubit.profileService.isEmailProvider()
                  ? () => _showChangePasswordDialog(context, profileCubit)
                  : null,
              child: const Text("Đổi mật khẩu"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<AuthCubit>().logout();
                Navigator.pushReplacementNamed(context, LoginScreen.route);
              },
              child: const Text("Đăng xuất"),
            ),

            const Divider(height: 32),

            // ================= KHU VỰC CỘNG TÁC VIÊN =================
            // Chỉ hiển thị khu vực này nếu người dùng đang là "user" bình thường
            if (user.role == 'user') ...[
              const Text(
                "Đăng ký Cộng tác viên",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              if (isLoadingCollab)
                const Center(child: CircularProgressIndicator())
              else if (collabStatus == 'pending')
                const Text(
                  'Yêu cầu của bạn đang chờ Admin phê duyệt...',
                  style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
                )
              else ...[
                if (collabStatus == 'rejected')
                  const Text(
                    'Yêu cầu trước đó đã bị từ chối. Bạn có thể thử lại.',
                    style: TextStyle(color: Colors.red),
                  ),

                ElevatedButton(
                  onPressed: _sendCollabRequest,
                  child: const Text('Gửi yêu cầu làm Cộng tác viên'),
                ),
              ],
            ],
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
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới (ít nhất 6 ký tự)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
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
                    setState(() => errorText = 'Mật khẩu phải từ 6 ký tự trở lên');
                    return;
                  }
                  if (newPass != confirmPass) {
                    setState(() => errorText = 'Mật khẩu xác nhận không khớp');
                    return;
                  }

                  profileCubit.changePassword(newPass);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đổi mật khẩu thành công!')),
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
