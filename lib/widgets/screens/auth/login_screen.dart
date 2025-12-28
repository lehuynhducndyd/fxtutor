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
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.Error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(notiBar("Đăng nhập thất bại, hãy kiểm tra lại", true));
          } else if (state.loadStatus == LoadStatus.Done) {
            Navigator.pushReplacementNamed(context, HomeScreen.route);
            context.read<MainCubit>().setSelected(DrawerItem.Home);
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
                  ElevatedButton(
                    child: Text("Đăng nhập"),
                    onPressed: () {
                      context.read<AuthCubit>().login(
                        emailController.text,
                        passwordController.text,
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text("Chưa có tài khoản? Đăng ký ngay"),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RegisterScreen.route);
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
