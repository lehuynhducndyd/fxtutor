import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/main_cubit.dart';
import 'package:fx_tutor/widgets/screens/home/topic_list_screen.dart';
import 'package:fx_tutor/widgets/screens/setting/setting_screen.dart';

import '../../../common/enum/drawer_item.dart';
import '../../../common/key_mapper.dart';
import '../../../services/ai_chat_service.dart';
import '../ai_chat/ai_chat_cubit.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../caculator/caculator.dart';
import '../content_manager/content_manager_screen.dart';
import '../menu/menu_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = 'HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        if (state.selected == DrawerItem.Home) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      builder: (context, state) {
        final isHome = state.selected == DrawerItem.Home;
        return Scaffold(
          appBar: AppBar(
            title: Text(_getTitle(state.selected)),
          ),
          body: Body(selectedIndex: _selectedIndex),

          bottomNavigationBar: isHome
              ? BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Học tập'),
                    BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Máy tính'),
                    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI'),
                  ],
                )
              : null,
          drawer: const Drawer(
            child: MenuScreen(),
          ),
        );
      },
    );
  }

  String _getTitle(DrawerItem selected) {
    switch (selected) {
      case DrawerItem.Home:
        return 'FX Tutor';
      case DrawerItem.Profile:
        return 'Profile';
      case DrawerItem.Setting:
        return 'Setting';
      case DrawerItem.ContentManager:
        return 'Content Manager';
      default:
        return '';
    }
  }
}

class Body extends StatelessWidget {
  final int selectedIndex;

  const Body({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        if (state.selected == DrawerItem.ContentManager) {
          Navigator.pushNamed(context, ContentManagerScreen.route);
        }
      },
      builder: (context, state) {
        if (state.selected == DrawerItem.Setting) {
          return SafeArea(child: SettingScreen());
        }
        if (state.selected == DrawerItem.Profile) {
          return const SafeArea(child: ProfileScreen());
        }

        // 3. Sử dụng MainView với index được truyền vào
        return SafeArea(
          child: MainView(selectedIndex: selectedIndex),
        );
      },
    );
  }
}

class MainView extends StatelessWidget {
  final int selectedIndex;

  const MainView({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    // 4. SỬ DỤNG INDEXEDSTACK ĐỂ GIỮ CÁC TRANG LUÔN SỐNG
    return IndexedStack(
      index: selectedIndex,
      children: [
        // Tab 0: Học tập
        TopicListScreen(),
        //NewWidget(),

        // Tab 1: Máy tính (Vẫn dùng Scaffold bên trong để cô lập layout)
        const Scaffold(
          body: KeepAliveWebView(url: 'https://calc-emu.vercel.app/'),
        ),

        // Tab 2: AI Chat
        BlocProvider(
          create: (context) => AiChatCubit(context.read<AiChatService>()),
          child: AiChatScreen(),
        ),
      ],
    );
  }
}

class NewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var text = KeyMapper.convert("[SHIFT][MENU][1][+][2]");
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Casio580',
          fontSize: 24,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: text),
        ],
      ),
    );
  }
}
