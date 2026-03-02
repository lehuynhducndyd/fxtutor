import 'package:flutter/material.dart';
import 'package:fx_tutor/widgets/screens/content_manager/contribute_content/admin_contribute_screen.dart';
import 'package:fx_tutor/widgets/screens/content_manager/guide_content/guide_content_manager_screen.dart';

import 'learning_content/learning_content_manager_screen.dart';

class ContentManagerScreen extends StatelessWidget {
  const ContentManagerScreen({super.key});
  static const String route = 'ContentManagerScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250, // Chiều rộng tối đa của mỗi Card
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // Giữ Card hình vuông hoặc tùy chỉnh theo ý muốn
          ),
          children: [
            _buildManagerCard(
              context,
              title: "Nội dung học",
              icon: Icons.book_outlined,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, LearningContentManagerScreen.route);
              },
            ),
            _buildManagerCard(
              context,
              title: "Hướng dẫn bấm máy",
              icon: Icons.calculate_outlined,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, GuideContentManagerScreen.route);
              },
            ),
            _buildManagerCard(
              context,
              title: "Kiểm duyệt đóng góp",
              icon: Icons.verified_user_outlined,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, AdminContributeScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm helper để tạo Card đồng nhất
  Widget _buildManagerCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
