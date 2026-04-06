import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  static const String route = 'InfoScreen';
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ================= HEADER: LOGO & TÊN APP =================
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calculate_rounded, // Bạn đổi thành Logo app nghen
                  size: 64,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "FX Tutor",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Phiên bản 1.0.0",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ================= 1. TÁC GIẢ =================

          // ================= 2. LỜI CẢM ƠN =================
          _buildSectionHeader(context, Icons.favorite, "Lời cảm ơn"),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Đặc biệt cảm ơn CalcWorld cùng các cộng tác viên khác cho ứng dụng Web-calc emulator, QR parser, KeyMap. Cảm ơn cộng đồng đã cung cấp các tài liệu và thư viện quý giá để hoàn thiện ứng dụng này.\n\n"
                "Nguồn tài liệu hướng dẫn sử dụng máy tính Casio fx-880BTG: Bản quyền thuộc về CASIO COMPUTER CO., LTD).",
                style: TextStyle(height: 1.5),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ================= 3. BẢN QUYỀN & MÃ NGUỒN (Chuẩn AGPL-3.0) =================
          _buildSectionHeader(context, Icons.gavel_rounded, "Giấy phép & Mã nguồn"),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Phần mềm này được phát hành dưới giấy phép GNU Affero General Public License v3.0 (AGPL-3.0). "
                    "Bạn có quyền tự do sử dụng, nghiên cứu, chia sẻ và sửa đổi phần mềm miễn là tuân thủ các điều khoản của giấy phép.",
                    style: TextStyle(height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text("Mã nguồn ứng dụng (Source Code)"),
                  subtitle: const Text("github.com/lehuynhduc/fx_tutor"), // Sửa lại link repo nha
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () {
                    // Chỗ này bạn có thể xài package url_launcher để mở link Github lên
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text("Mã nguồn Web-calc (Source Code)"),
                  subtitle: const Text("github.com/lehuynhduc/calc-emu"), // Sửa lại link repo nha
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () {
                    // Chỗ này bạn có thể xài package url_launcher để mở link Github lên
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text("Xem toàn bộ giấy phép phần mềm"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Hàm có sẵn của Flutter, show tất cả license của các thư viện đang xài
                    showLicensePage(
                      context: context,
                      applicationName: 'FX Tutor',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 Lê Huỳnh Đức. Licensed under AGPL-3.0',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ================= 4. LIÊN HỆ =================
          _buildSectionHeader(context, Icons.contact_mail, "Liên hệ"),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text("lehuynhducndyd@gmail.com"),
            ),
          ),
          const SizedBox(height: 40),

          // Dòng chữ bản quyền ở cuối cùng
          Center(
            child: Text(
              "© ${DateTime.now().year} Lê Huỳnh Đức. All rights reserved.",
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Hàm hỗ trợ vẽ tiêu đề cho từng khu vực
  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
