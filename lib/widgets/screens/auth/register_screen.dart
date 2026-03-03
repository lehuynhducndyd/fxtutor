import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/widgets/screens/auth/auth_cubit.dart';

import '../../../common/enum/load_status.dart';
import '../../../services/auth_service.dart';
import '../../common_widgets/noti_bar.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String route = 'RegisterScreen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Dọn dẹp controller để giải phóng bộ nhớ
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(context.read<AuthService>()),
      child: Page(
        emailController: emailController,
        passwordController: passwordController,
        confirmPasswordController: confirmPasswordController,
      ),
    );
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              notiBar("Đăng ký thất bại, hãy kiểm tra lại", true),
            );
          } else if (state.loadStatus == LoadStatus.Done) {
            // Đăng ký thành công thì chuyển về màn hình đăng nhập
            Navigator.pushReplacementNamed(context, LoginScreen.route);
            ScaffoldMessenger.of(context).showSnackBar(
              notiBar("Đăng ký thành công! Vui lòng đăng nhập.", false),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.loadStatus == LoadStatus.Loading;

          return Center(
            // Cuộn được để không bị tràn UI khi hiện bàn phím
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Trải dài các thành phần
                  children: [
                    // ================= HEADER / LOGO =================
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Tạo tài khoản mới",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Vui lòng điền thông tin bên dưới",
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Xác nhận mật khẩu",
                        prefixIcon: const Icon(Icons.check_circle_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ================= NÚT ĐĂNG KÝ =================
                    FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus(); // Ẩn bàn phím khi bấm
                              context.read<AuthCubit>().register(
                                emailController.text,
                                passwordController.text,
                                confirmPasswordController.text,
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
                          : const Text("Đăng ký", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 24),

                    // ================= NÚT CHUYỂN SANG ĐĂNG NHẬP =================
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(context, LoginScreen.route);
                            },
                      child: RichText(
                        text: TextSpan(
                          text: "Đã có tài khoản? ",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                          children: [
                            TextSpan(
                              text: "Đăng nhập ngay",
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
