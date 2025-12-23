import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/main_cubit.dart';
import 'package:fx_tutor/widgets/screens/setting/setting_screen.dart';

import '../../../common/enum/drawer_item.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../caculator/caculator.dart';
import '../menu/menu_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = 'HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Hàm helper để lấy tiêu đề dựa trên state
  String _getTitle(DrawerItem item) {
    switch (item) {
      case DrawerItem.Setting:
        return "Cài đặt";
      case DrawerItem.Profile:
        return "Hồ sơ";
      case DrawerItem.Home:
      default:
        return "FxTutor";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dùng BlocConsumer để vừa lắng nghe logic (Listener) vừa vẽ lại UI (Builder)
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        // Kiểm tra điều kiện: Nếu quay về Home VÀ PageController đã được gắn vào PageView
        if (state.selected == DrawerItem.Home) {
          // Sử dụng hasClients để tránh lỗi "not attached"
          if (_pageController.hasClients && _selectedIndex != 0) {
            _selectedIndex = 0;
            _pageController.jumpToPage(0);
          } else {
            // Nếu chưa có clients (do vừa từ Setting về), chỉ cần reset biến index
            // PageView sẽ tự khởi tạo ở page 0 nếu initialPage của controller là 0
            _selectedIndex = 0;
          }
        }
      },
      builder: (context, state) {
        // Kiểm tra xem có đang ở trang Home không
        final isHome = state.selected == DrawerItem.Home;

        return Scaffold(
          appBar: AppBar(
            // Tiêu đề tự động cập nhật theo state
            title: Text(_getTitle(state.selected)),
          ),

          body: Body(pageController: _pageController),

          // QUAN TRỌNG: Chỉ hiện BottomBar khi đang ở Home
          // Nếu không phải Home, trả về null (sẽ ẩn đi)
          bottomNavigationBar: isHome
              ? BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() => _selectedIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Học tập'),
                    BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Máy tính'),
                    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI'),
                  ],
                )
              : null, // <--- Ẩn BottomBar tại đây

          drawer: const Drawer(
            child: MenuScreen(),
          ),
        );
      },
    );
  }
}

class Body extends StatelessWidget {
  final PageController pageController;
  const Body({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state.selected == DrawerItem.Setting) {
          return SafeArea(child: SettingScreen());
        }
        if (state.selected == DrawerItem.Profile) {
          return SafeArea(child: ProfileScreen());
        }
        return SafeArea(
          child: MainView(pageController: pageController),
        );
      },
    );
  }
}

class MainView extends StatelessWidget {
  final PageController pageController;
  const MainView({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    // 4. PageView là một Box Widget, nó sẽ hoạt động tốt khi nằm trong SafeArea của Scaffold
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(), // Chặn vuốt tay để dùng BottomNav
      children: [
        const Center(child: Text("Học tập")),
        const Scaffold(body: KeepAliveWebView(url: 'https://calc-emu.vercel.app/')),
        AiChatScreen(),
      ],
    );
  }
}
