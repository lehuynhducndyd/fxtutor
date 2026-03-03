import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  static const String route = 'GuideScreen';
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hướng dẫn sử dụng"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ================= LỜI CHÀO =================
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.waving_hand_rounded, size: 40, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chào mừng bạn!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Dưới đây là cẩm nang giúp bạn sử dụng FX Tutor một cách hiệu quả nhất.",
                          style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ================= CÁC MỤC HƯỚNG DẪN =================
          _buildGuideSection(
            context: context,
            icon: Icons.calculate_outlined,
            title: "1. Sử dụng Máy tính giả lập (Emulator)",
            content:
                "• Mở tab 'Giả lập' để sử dụng máy tính trực tiếp trên điện thoại.\n"
                "• Giao diện và các nút bấm được thiết kế giống hệt máy tính Casio thật.\n"
                "• Bạn có thể dùng nó để thực hành ngay các bài học hoặc công thức mà không cần mang theo máy tính vật lý.",
          ),
          _buildGuideSection(
            context: context,
            icon: Icons.calculate_outlined,
            title: "1. Lấy KeyLog Máy tính giả lập (Emulator)",
            content:
                "• Mở tab 'Giả lập' để sử dụng máy tính trực tiếp trên điện thoại.\n"
                "• Giao diện và các nút bấm được thiết kế giống hệt máy tính Casio thật.\n"
                "• Bạn có thể dùng nó để thực hành ngay các bài học hoặc công thức mà không cần mang theo máy tính vật lý.",
          ),

          _buildGuideSection(
            context: context,
            icon: Icons.menu_book_rounded,
            title: "2. Học tập & Xem Hướng dẫn",
            content:
                "• Tại trang chủ, bạn có thể duyệt qua các 'Chủ đề học tập' hoặc 'Hướng dẫn máy tính'.\n"
                "• Sử dụng thanh tìm kiếm ở trên cùng để tìm nhanh bài học hoặc thủ thuật bấm máy bạn cần (ví dụ: 'Giải phương trình bậc 2', 'Số phức').\n"
                "• Bấm vào từng bài học để xem chi tiết lý thuyết và các khối nội dung.",
          ),

          _buildGuideSection(
            context: context,
            icon: Icons.handshake_outlined,
            title: "3. Đăng ký làm Cộng tác viên",
            content:
                "• Nếu bạn muốn chia sẻ kiến thức, hãy vào mục 'Hồ sơ' (Profile) và bấm 'Gửi yêu cầu làm Cộng tác viên'.\n"
                "• Sau khi Admin phê duyệt, bạn sẽ có quyền truy cập vào khu vực Quản lý nội dung để tự do thêm/sửa/xóa các bài giảng và hướng dẫn bấm máy của riêng mình.",
          ),

          _buildGuideSection(
            context: context,
            icon: Icons.manage_accounts_outlined,
            title: "4. Quản lý Tài khoản",
            content:
                "• Vào tab 'Hồ sơ' để cập nhật Tên hiển thị của bạn.\n"
                "• Bạn có thể Đổi mật khẩu bất cứ lúc nào (chỉ áp dụng cho tài khoản đăng ký bằng Email, không áp dụng cho tài khoản Google).\n"
                "• Trạng thái Cộng tác viên của bạn cũng sẽ được hiển thị và cập nhật liên tục tại đây.",
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // ================= MỤC FAQ (HỎI ĐÁP) =================
          Text(
            "Câu hỏi thường gặp (FAQ)",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          _buildFAQItem(
            context: context,
            question: "Tại sao tôi không thấy bài học nào?",
            answer:
                "Có thể danh mục bạn chọn chưa có nội dung nào được cập nhật, hoặc bạn đang gặp vấn đề về kết nối mạng. Hãy thử vuốt từ trên xuống (Pull to refresh) để tải lại dữ liệu nhé.",
          ),
          _buildFAQItem(
            context: context,
            question: "Làm sao để biết yêu cầu Cộng tác viên đã được duyệt?",
            answer:
                "Bạn hãy vào trang Hồ sơ, mục 'Đăng ký Cộng tác viên' sẽ hiển thị trạng thái hiện tại (Đang chờ duyệt, Đã duyệt, hoặc Bị từ chối). Khi được duyệt, vai trò của bạn sẽ tự động chuyển thành 'COLLABORATOR'.",
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Hàm hỗ trợ tạo các khung Hướng dẫn (bung xòe được)
  Widget _buildGuideSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: const Border(), // Xóa hai cái gạch viền mặc định của ExpansionTile khi mở ra
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(height: 1.5, color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hỗ trợ tạo mục FAQ
  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Q: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
              ),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "A: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.secondary,
                ),
              ),
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(height: 1.5, color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
