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
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authService),
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
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.Error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(notiBar("Đăng ký thất bại, hãy kiểm tra lại", true));
          } else if (state.loadStatus == LoadStatus.Done) {
            Navigator.pushReplacementNamed(context, LoginScreen.route);
          }
        },
        builder: (context, state) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Email"),
                    controller: emailController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Password"),
                    controller: passwordController,
                    obscureText: true,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Confirm Password"),
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                  ElevatedButton(
                    child: Text("Đăng ký"),
                    onPressed: () {
                      context.read<AuthCubit>().register(
                        emailController.text,
                        passwordController.text,
                        confirmPasswordController.text,
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text("Đã có tài khoản? Đăng nhập ngay"),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, LoginScreen.route);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
