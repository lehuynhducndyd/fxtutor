import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  static const String route = 'GuideScreen';
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 24),
          // ================= LỜI CHÀO =================
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
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
                          "Dưới đây là hướng dẫn giúp bạn sử dụng FX Tutor một cách hiệu quả nhất.",
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
            title: "1. Đăng ký làm Cộng tác viên",
            content:
                "• Nếu bạn muốn chia sẻ kiến thức, hãy vào mục 'Hồ sơ' và bấm 'Gửi yêu cầu làm Cộng tác viên'.\n"
                "• Sau khi Admin phê duyệt, bạn sẽ có quyền truy cập vào khu vực Quản lý nội dung để tự do thêm/sửa/xóa các bài giảng và hướng dẫn bấm máy của riêng mình.",
          ),
          _buildGuideSection(
            context: context,
            title: "2. Thêm bài học và hướng dẫn bấm máy",
            content:
                "• Bài học sẽ được hiển thị cho người học ở trang chủ và hướng dẫn bấm máy dùng để cung cấp dữ liệu cho AI, do đó bạn nên cung cấp hướng dẫn bấm máy cho bài học nữa nhé.\n"
                "• Hãy cố gắng thêm mô tả cho ảnh nếu có thể.\n"
                "• Bạn có thể tự thêm dữ liệu cho các khôi nội dung hoặc sử dụng các công cụ hỗ trợ lấy LateX, Keylog và Screenshoot ở trên cùng",
          ),
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: ExpansionTile(
              title: Text(
                "3. Lấy Keylog và ảnh chụp màn hình",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              shape: const Border(), // Xóa hai cái gạch viền mặc định của ExpansionTile khi mở ra
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    "Tại màn hình bắt đầu, chọn tên model (RAM tạm thời)",
                    style: TextStyle(height: 1.5, color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Image.asset(
                    "assets/img/Slice1.png",
                    width: 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // ================= MỤC FAQ (HỎI ĐÁP) =================
          Text(
            "Các lưu ý",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 0,
            color: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          """Nếu bạn không thao tác được với latex, hãy sử dụng hình ảnh để thay thế nhé""",
                          style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          """Nếu trình giả lập không hoạt động vì lý do nào đó, hãy sử dụng classpad.net từ Casio""",
                          style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          """Câu trả lời của AI chỉ mang tính chất tham khảo, hãy gửi email cho đội ngũ quản trị viên để được giải đáp sâu hơn""",
                          style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Hàm hỗ trợ tạo các khung Hướng dẫn (bung xòe được)
  Widget _buildGuideSection({
    required BuildContext context,
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
