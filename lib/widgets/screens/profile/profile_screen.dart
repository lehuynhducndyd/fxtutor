import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/auth/auth_cubit.dart';
import 'package:fx_tutor/widgets/screens/profile/profile_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/auth_service.dart';
import '../../../services/collaborator_service.dart';
import '../../../services/email_service.dart'; // Import EmailService
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

  // Khởi tạo EmailService
  final EmailService _emailService = EmailService();

  // Các biến để quản lý việc gọi Service trực tiếp
  String? collabStatus;
  bool isLoadingCollab = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    _checkCollabStatus();
  }

  @override
  void dispose() {
    nameController.dispose();
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
      // 1. Lưu yêu cầu vào database
      await CollaboratorService().requestToCollaborate();

      // 2. Lấy email người dùng hiện tại
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userEmail = currentUser?.email ?? 'Người dùng ẩn danh';

      // 3. Bắn email cho Admin (chạy ngầm, không dùng await để UI mượt mà)
      _notifyAdminViaEmail(userEmail);

      // 4. Cập nhật giao diện
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi yêu cầu thành công!')),
        );
        setState(() => isLoadingCollab = true);
        await _checkCollabStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // Hàm soạn và gửi email cho QTV
  Future<void> _notifyAdminViaEmail(String userEmail) async {
    final htmlBody =
        '''
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eaeaea; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <h2 style="color: #0d6efd; border-bottom: 2px solid #0d6efd; padding-bottom: 8px;">Yêu cầu Cộng tác viên mới!</h2>
        <p>Hệ thống FX Tutor vừa nhận được một đơn đăng ký làm Cộng tác viên nội dung.</p>
        
        <p><strong>Tài khoản đăng ký:</strong> <span style="color: #0d6efd; font-weight: bold;">$userEmail</span></p>
        
        <p style="margin-top: 32px; font-size: 14px;">Vui lòng truy cập <strong>Trang Quản lý người dùng > Kiểm duyệt yêu cầu cộng tác</strong> trên ứng dụng để xem xét và phân quyền cho người dùng này.</p>
        <hr style="border: none; border-top: 1px solid #eaeaea; margin: 24px 0;">
        <p style="font-size: 12px; color: #adb5bd; text-align: center;">Đây là email thông báo tự động từ hệ thống FX Tutor.</p>
      </div>
    ''';

    try {
      await _emailService.sendEmail(
        toEmail: 'lehuynhducndyd@gmail.com', // Bắn thẳng về email QTV
        subject: 'FX Tutor - Yêu cầu Cộng tác viên mới từ $userEmail',
        htmlContent: htmlBody,
      );
    } catch (e) {
      print('Lỗi gửi email yêu cầu CTV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
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

        final colorScheme = Theme.of(context).colorScheme;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ================= KHU VỰC THÔNG TIN CÁ NHÂN =================
            Card(
              elevation: 0,
              color: colorScheme.secondaryContainer.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    child: const Icon(Icons.person),
                  ),
                  title: Text(
                    user.email ?? "Chưa có email",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Vai trò: ${user.role?.toUpperCase()}"),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ================= CẬP NHẬT TÊN =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Tên hiển thị",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: FilledButton(
                    onPressed: () {
                      context.read<ProfileCubit>().updateProfile(fullName: nameController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đổi tên thành công!')),
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cập nhật"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ================= CÁC NÚT CHỨC NĂNG =================
            Row(
              children: [
                FilledButton.icon(
                  label: const Text("Đổi mật khẩu"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: profileCubit.profileService.isEmailProvider()
                      ? () => _showChangePasswordDialog(context, profileCubit)
                      : null,
                ),
                const SizedBox(width: 12),

                FilledButton.icon(
                  label: const Text("Đăng xuất"),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                    Navigator.pushReplacementNamed(context, LoginScreen.route);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 32),

            // ================= KHU VỰC CỘNG TÁC VIÊN =================
            if (user.role == 'user') ...[
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.handshake_outlined, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            "Đăng ký Cộng tác viên",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (isLoadingCollab)
                        const Center(child: CircularProgressIndicator())
                      else if (collabStatus == 'pending')
                        Row(
                          children: [
                            const Icon(Icons.pending_actions, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Yêu cầu của bạn đang chờ Admin phê duyệt...',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        if (collabStatus == 'rejected')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Yêu cầu trước đó đã bị từ chối. Bạn có thể thử lại.',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        FilledButton.tonal(
                          onPressed: _sendCollabRequest,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Gửi yêu cầu làm Cộng tác viên'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.lock_reset),
                SizedBox(width: 8),
                Text('Đổi mật khẩu'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      errorText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    helperText: 'Ít nhất 6 ký tự',
                    prefixIcon: const Icon(Icons.password),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.check_circle_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              FilledButton(
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
