import 'package:flutter/material.dart';
import 'package:fx_tutor/widgets/screens/user_manager/admin_collaborator_screen.dart';
import 'package:fx_tutor/widgets/screens/user_manager/user_management_screen.dart';

class UserManagerScreen extends StatelessWidget {
  static const String route = 'UserManagerScreen';

  const UserManagerScreen({super.key});

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
              title: "Kiểm duyệt yêu cầu cộng tác",
              icon: Icons.verified_user_outlined,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, AdminCollaboratorScreen.route);
              },
            ),
            _buildManagerCard(
              context,
              title: "Quản lý người dùng",
              icon: Icons.supervised_user_circle_outlined,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, UserManagementScreen.route);
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
