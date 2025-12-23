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
  final authService = AuthService();
  final profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(authService)),
        BlocProvider(create: (context) => ProfileCubit(profileService)..loadUser()),
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
        print(user);
        if (user.id.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          children: [
            Text("${user.email}"),
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
