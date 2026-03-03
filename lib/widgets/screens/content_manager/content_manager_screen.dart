import 'package:flutter/material.dart';
import 'package:fx_tutor/widgets/screens/content_manager/contribute_content/admin_contribute_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_content_manager_screen.dart';

import 'learning_content/learning_content_manager_screen.dart';

class ContentManagerScreen extends StatelessWidget {
  const ContentManagerScreen({super.key});
  static const String route = 'ContentManagerScreen';

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
                  maxCrossAxisExtent: 220,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9, // Thẻ hơi cao hơn hình vuông một chút
                ),
                children: [
                  // SỬ DỤNG MÀU TƯƠI HƠN (Material Color Palettes)
                  _buildManagerCard(
                    context,
                    title: "Nội dung học",
                    icon: Icons.menu_book_rounded,
                    iconColor: Colors.blueAccent.shade400, // Màu xanh tươi nổi bật
                    onTap: () {
                      Navigator.pushNamed(context, LearningContentManagerScreen.route);
                    },
                  ),
                  _buildManagerCard(
                    context,
                    title: "Hướng dẫn\nbấm máy",
                    icon: Icons.calculate_rounded,
                    iconColor: Colors.orangeAccent.shade700, // Màu cam đậm tươi
                    onTap: () {
                      Navigator.pushNamed(context, GuideContentManagerScreen.route);
                    },
                  ),
                  _buildManagerCard(
                    context,
                    title: "Kiểm duyệt\nđóng góp",
                    icon: Icons.verified_user_rounded,
                    iconColor: Colors.tealAccent.shade700, // Màu xanh ngọc tươi
                    onTap: () {
                      Navigator.pushNamed(context, AdminContributeScreen.route);
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

  // Hàm helper để tạo Card đồng nhất chuẩn M3 với Icon tươi hơn
  Widget _buildManagerCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor, // Chỉ cần nhận 1 màu icon tươi
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
              // Khu vực chứa Icon (Đổi sang viền và icon màu tươi)
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
