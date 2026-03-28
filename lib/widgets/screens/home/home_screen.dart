import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/main_cubit.dart';
import 'package:fx_tutor/route.dart';
import 'package:fx_tutor/widgets/screens/guide/guide_screen.dart';
import 'package:fx_tutor/widgets/screens/home/topic_list_screen.dart';
import 'package:fx_tutor/widgets/screens/setting/setting_screen.dart';

import '../../../common/enum/drawer_item.dart';
import '../../../services/ai_chat_service.dart';
import '../../../services/profile_service.dart';
import '../ai_chat/ai_chat_cubit.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../caculator/calculator_screen.dart'; // Giả sử KeepAliveWebView nằm trong này
import '../content_manager/content_manager_screen.dart';
import '../contribute/contribute_screen.dart';
import '../info/info_screen.dart';
import '../menu/menu_screen.dart';
import '../profile/profile_cubit.dart';
import '../profile/profile_screen.dart';
import '../user_manager/user_manager_screen.dart';
import 'QrGuideScreen.dart';

// [NOTE] Import màn hình CasioQr nếu bạn đã định nghĩa nó ở file khác
// import '../qr_scanner/casio_qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = 'HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Quy ước Index mới: 0 = Học tập, 1 = QR & HDSD, 2 = Máy tính, 3 = AI Chat
  int _selectedIndex = 0;

  // Tăng lên 4 NavigatorKeys cho 4 tab riêng biệt
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // 0: Học tập
    GlobalKey<NavigatorState>(), // 1: QR & HDSD
    GlobalKey<NavigatorState>(), // 2: Máy tính
    GlobalKey<NavigatorState>(), // 3: AI Chat
  ];

  @override
  Widget build(BuildContext context) {
    // Xác định màn hình lớn (Tablet, Web, PC) với breakpoint 800
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    // Tự động điều chỉnh index nếu đang ở tab Máy tính (2) mà mở to màn hình
    if (isLargeScreen && _selectedIndex == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    }

    return BlocProvider(
      create: (context) => ProfileCubit(context.read<ProfileService>())..loadUser(),
      child: BlocConsumer<MainCubit, MainState>(
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
                currentNavigator.pop(); // Pop nav con của tab hiện tại
              } else {
                if (_selectedIndex != 0) {
                  setState(() => _selectedIndex = 0); // Về tab Home nếu ko pop được nữa
                } else {
                  // Xử lý thoát app ở đây
                }
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(_getTitle(state.selected)),
              ),
              body: Body(
                selectedIndex: _selectedIndex,
                navigatorKeys: _navigatorKeys,
                isLargeScreen: isLargeScreen,
              ),
              bottomNavigationBar: isHome
                  ? BottomNavigationBar(
                      type: BottomNavigationBarType.fixed, // Cần thiết khi có từ 4 item trở lên
                      // Map index UI với index thực tế
                      currentIndex: isLargeScreen
                          ? (_selectedIndex == 3
                                ? 2
                                : _selectedIndex) // Nếu chọn AI(3) thì nút sáng ở UI là index 2
                          : _selectedIndex,
                      onTap: (index) {
                        int targetIndex = index;
                        if (isLargeScreen && index == 2) {
                          targetIndex = 3; // Tab AI luôn nằm ở _navigatorKeys[3]
                        }

                        // Nếu chạm lại vào tab đang mở -> pop về route đầu tiên (reset tab)
                        if (_selectedIndex == targetIndex) {
                          _navigatorKeys[targetIndex].currentState?.popUntil(
                            (route) => route.isFirst,
                          );
                        } else {
                          setState(() => _selectedIndex = targetIndex);
                        }
                      },
                      items: isLargeScreen
                          ? const [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.grid_view_rounded),
                                label: 'Học tập',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.qr_code_scanner_rounded),
                                label: 'QR & HDSD',
                              ),
                              // Ẩn tab Máy tính trên màn hình lớn vì nó đã cố định ở bên phải
                              BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'AI'),
                            ]
                          : const [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.grid_view_rounded),
                                label: 'Học tập',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.qr_code_scanner_rounded),
                                label: 'QR & HDSD',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.calculate_rounded),
                                label: 'Máy tính',
                              ),
                              BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'AI'),
                            ],
                    )
                  : null,
              drawer: const Drawer(
                child: MenuScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _getTitle(DrawerItem selected) {
  switch (selected) {
    case DrawerItem.Home:
      return 'FX Tutor';
    case DrawerItem.Profile:
      return 'Hồ sơ';
    case DrawerItem.Setting:
      return 'Cài đặt';
    case DrawerItem.ContentManager:
      return 'Quản lý nội dung';
    case DrawerItem.UserManager:
      return 'Quản lý người dùng';
    case DrawerItem.Contribute:
      return 'Đóng góp';
    case DrawerItem.Info:
      return 'Thông tin';
    case DrawerItem.Guide:
      return 'Hướng dẫn';
    default:
      return '';
  }
}

class Body extends StatelessWidget {
  final int selectedIndex;
  final List<GlobalKey<NavigatorState>> navigatorKeys;
  final bool isLargeScreen;

  const Body({
    super.key,
    required this.selectedIndex,
    required this.navigatorKeys,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state.selected == DrawerItem.Setting) return const SafeArea(child: SettingScreen());
        if (state.selected == DrawerItem.ContentManager)
          return const SafeArea(child: ContentManagerScreen());
        if (state.selected == DrawerItem.Profile) return const SafeArea(child: ProfileScreen());
        if (state.selected == DrawerItem.UserManager)
          return const SafeArea(child: UserManagerScreen());
        if (state.selected == DrawerItem.Contribute)
          return const SafeArea(child: ContributeScreen());
        if (state.selected == DrawerItem.Info) return const SafeArea(child: InfoScreen());
        if (state.selected == DrawerItem.Guide) return const SafeArea(child: GuideScreen());

        return SafeArea(
          child: MainView(
            selectedIndex: selectedIndex,
            navigatorKeys: navigatorKeys,
            isLargeScreen: isLargeScreen,
          ),
        );
      },
    );
  }
}

class MainView extends StatelessWidget {
  final int selectedIndex;
  final List<GlobalKey<NavigatorState>> navigatorKeys;
  final bool isLargeScreen;

  const MainView({
    super.key,
    required this.selectedIndex,
    required this.navigatorKeys,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    // 0: Tab Học tập
    final hocTapTab = TabNavigator(
      navigatorKey: navigatorKeys[0],
      initialRoute: TopicListScreen.route,
    );

    // 1: Tab QR & HDSD (Tab Mới)
    final qrGuideTab = TabNavigator(
      navigatorKey: navigatorKeys[1],
      rootWidget: const QrGuideScreen(),
    );

    // 2: Tab Máy tính
    final mayTinhTab = TabNavigator(
      navigatorKey: navigatorKeys[2],
      rootWidget: const Scaffold(
        body: KeepAliveWebView(url: 'https://calc-emu.vercel.app/'),
      ),
    );

    // 3: Tab AI Chat
    final aiTab = TabNavigator(
      navigatorKey: navigatorKeys[3],
      rootWidget: BlocProvider(
        create: (context) => AiChatCubit(context.read<AiChatService>()),
        child: const AiChatScreen(),
      ),
    );

    // XỬ LÝ CHIA MÀN HÌNH (LARGE SCREEN)
    if (isLargeScreen) {
      return Row(
        children: [
          // Cột trái (Tỉ lệ 2): Hiển thị Học tập (0), QR (1) hoặc AI (3)
          Expanded(
            flex: 2,
            child: IndexedStack(
              // Nếu đang chọn AI (3) thì map nó về index 2 trong IndexedStack này
              index: selectedIndex == 3 ? 2 : selectedIndex,
              children: [hocTapTab, qrGuideTab, aiTab],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1), // Đường kẻ dọc chia cắt
          // Cột phải (Tỉ lệ 1): Luôn luôn hiển thị Máy tính
          Expanded(
            flex: 1,
            child: mayTinhTab,
          ),
        ],
      );
    }

    // MÀN HÌNH NHỎ (MOBILE)
    return IndexedStack(
      index: selectedIndex,
      children: [hocTapTab, qrGuideTab, mayTinhTab, aiTab],
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
        return mainRoute(settings); // Đảm bảo mainRoute đã cấu hình điều hướng chung
      },
    );
  }
}
