import 'package:flutter/material.dart';
import 'package:fx_tutor/widgets/screens/user_manager/admin_collaborator_screen.dart';
import 'package:fx_tutor/widgets/screens/user_manager/user_management_screen.dart';

class UserManagerScreen extends StatelessWidget {
  static const String route = 'UserManagerScreen';

  const UserManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= GRID MENU =================
            Expanded(
              child: GridView(
                physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn nảy mượt mà
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220, // Kích thước cân đối trên cả điện thoại và tablet
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9, // Thẻ hơi cao hơn hình vuông một chút
                ),
                children: [
                  _buildManagerCard(
                    context,
                    title: "Kiểm duyệt yêu cầu cộng tác",
                    icon: Icons.verified_user_rounded,
                    iconColor: Colors.blueAccent.shade400, // Màu xanh tươi nổi bật
                    onTap: () {
                      Navigator.pushNamed(context, AdminCollaboratorScreen.route);
                    },
                  ),
                  _buildManagerCard(
                    context,
                    title: "Quản lý người dùng",
                    icon: Icons.manage_accounts_rounded, // Đổi icon nhìn chuyên nghiệp hơn
                    iconColor: Colors.orangeAccent.shade700, // Màu cam đậm tươi
                    onTap: () {
                      Navigator.pushNamed(context, UserManagementScreen.route);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm helper để tạo Card đồng nhất chuẩn M3 với Icon tươi
  Widget _buildManagerCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0, // Bỏ bóng đổ chuẩn M3
      color: colorScheme.surfaceContainerHighest.withOpacity(0.4), // Nền thẻ nhạt
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: iconColor.withOpacity(0.15), // Màu hiệu ứng sóng nước nhạt theo màu icon
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Khu vực chứa Icon (Viền và icon màu tươi)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1), // Nền vòng tròn cực nhạt
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1.5,
                  ), // Viền vòng tròn
                ),
                child: Icon(icon, size: 36, color: iconColor), // Icon màu tươi chủ đạo
              ),
              const SizedBox(height: 16),
              // Tiêu đề
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3, // Khoảng cách dòng cho chữ có 2 dòng
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
