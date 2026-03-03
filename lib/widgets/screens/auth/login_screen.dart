import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/drawer_item.dart';
import 'package:fx_tutor/main_cubit.dart';
import 'package:fx_tutor/widgets/screens/auth/register_screen.dart';
import 'package:fx_tutor/widgets/screens/home/home_screen.dart';

import '../../../common/enum/load_status.dart';
import '../../../services/auth_service.dart';
import '../../common_widgets/noti_bar.dart';
import 'auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String route = 'LoginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Thêm hàm dọn dẹp controller để tránh tràn bộ nhớ (Memory Leak)
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(context.read<AuthService>()),
      child: Page(emailController: emailController, passwordController: passwordController),
    );
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              notiBar("Đăng nhập thất bại, hãy kiểm tra lại", true),
            );
          } else if (state.loadStatus == LoadStatus.Done) {
            Navigator.pushReplacementNamed(context, HomeScreen.route);
            context.read<MainCubit>().setSelected(DrawerItem.Home);
          }
        },
        builder: (context, state) {
          final isLoading = state.loadStatus == LoadStatus.Loading;

          return Center(
            // Bọc ScrollView để không bị lỗi tràn UI khi bàn phím bật lên
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Kéo dãn các thành phần ra hết chiều ngang
                  children: [
                    // ================= HEADER / LOGO =================
                    Icon(
                      Icons.lock_person_rounded,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Xin chào!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Vui lòng đăng nhập để tiếp tục",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 40),

                    // ================= FORM NHẬP LIỆU =================
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Mật khẩu",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ================= NÚT ĐĂNG NHẬP CHÍNH =================
                    FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              // Tự động bỏ focus bàn phím khi bấm đăng nhập
                              FocusScope.of(context).unfocus();
                              context.read<AuthCubit>().login(
                                emailController.text,
                                passwordController.text,
                              );
                            },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 24),

                    // ================= DÒNG KẺ HOẶC =================
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Hoặc", style: TextStyle(color: colorScheme.outline)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ================= NÚT GOOGLE =================
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AuthCubit>().loginGoogle();
                            },
                      // Icon Google có thể thay bằng thư viện FontAwesome hoặc Asset image
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text("Đăng nhập bằng Google", style: TextStyle(fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: colorScheme.outline),
                        foregroundColor: colorScheme.onSurface, // Chữ màu đen/xám tối chuẩn M3
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ================= NÚT CHUYỂN SANG ĐĂNG KÝ =================
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(context, RegisterScreen.route);
                            },
                      child: RichText(
                        text: TextSpan(
                          text: "Chưa có tài khoản? ",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                          children: [
                            TextSpan(
                              text: "Đăng ký ngay",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
