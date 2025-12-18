import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/main_cubit.dart';
import 'package:fx_tutor/widgets/screens/setting/setting_screen.dart';

import '../../../common/enum/drawer_item.dart';
import '../menu/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = 'HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giải toán')),
      body: Body(),
      drawer: Drawer(
        child: MenuScreen(),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state.selected == DrawerItem.Setting) {
          return SafeArea(
            child: Center(
              child: SettingScreen(),
            ),
          );
        } else {
          return SafeArea(
            child: MainView(),
          );
        }
      },
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        Placeholder(),
        Center(
          child: Text("Máy tính"),
        ),
        Center(
          child: Text("AI"),
        ),
      ],
    );
  }
}
