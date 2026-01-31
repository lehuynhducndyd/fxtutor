import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/main_cubit.dart';
import 'package:fx_tutor/route.dart';
import 'package:fx_tutor/widgets/screens/home/topic_list_screen.dart';
import 'package:fx_tutor/widgets/screens/setting/setting_screen.dart';

import '../../../common/enum/drawer_item.dart';
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
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

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
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            final NavigatorState? currentNavigator = _navigatorKeys[_selectedIndex].currentState;
            if (currentNavigator != null && currentNavigator.canPop()) {
              currentNavigator.pop();
            } else {
              // Nếu không thể pop trong tab, có thể xử lý thoát app hoặc về tab đầu tiên
              if (_selectedIndex != 0) {
                setState(() => _selectedIndex = 0);
              } else {
                // Thoát app (cần import services hoặc dùng SystemNavigator)
              }
            }
          },
          child: Scaffold(
            appBar: isHome
                ? AppBar(
                    title: Text(_getTitle(state.selected)),
                  )
                : AppBar(
                    title: Text(_getTitle(state.selected)),
                  ),
            body: Body(
              selectedIndex: _selectedIndex,
              navigatorKeys: _navigatorKeys,
            ),
            bottomNavigationBar: isHome
                ? BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      if (_selectedIndex == index) {
                        // Nếu nhấn lại vào tab đang chọn, quay về trang đầu của tab đó
                        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
                      } else {
                        setState(() => _selectedIndex = index);
                      }
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
  final List<GlobalKey<NavigatorState>> navigatorKeys;

  const Body({
    super.key,
    required this.selectedIndex,
    required this.navigatorKeys,
  });

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

        return SafeArea(
          child: MainView(
            selectedIndex: selectedIndex,
            navigatorKeys: navigatorKeys,
          ),
        );
      },
    );
  }
}

class MainView extends StatelessWidget {
  final int selectedIndex;
  final List<GlobalKey<NavigatorState>> navigatorKeys;

  const MainView({
    super.key,
    required this.selectedIndex,
    required this.navigatorKeys,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: [
        // Tab 0: Học tập
        TabNavigator(
          navigatorKey: navigatorKeys[0],
          initialRoute: TopicListScreen.route,
        ),

        // Tab 1: Máy tính
        TabNavigator(
          navigatorKey: navigatorKeys[1],
          rootWidget: const Scaffold(
            body: KeepAliveWebView(url: 'https://calc-emu.vercel.app/'),
          ),
        ),

        // Tab 2: AI Chat
        TabNavigator(
          navigatorKey: navigatorKeys[2],
          rootWidget: BlocProvider(
            create: (context) => AiChatCubit(context.read<AiChatService>()),
            child: const AiChatScreen(),
          ),
        ),
      ],
    );
  }
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String? initialRoute;
  final Widget? rootWidget;

  const TabNavigator({
    super.key,
    required this.navigatorKey,
    this.initialRoute,
    this.rootWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/' || settings.name == initialRoute) {
          return MaterialPageRoute(
            builder: (context) => rootWidget ?? const TopicListScreen(),
            settings: settings,
          );
        }
        // Sử dụng logic routing tập trung từ route.dart
        return mainRoute(settings);
      },
    );
  }
}
