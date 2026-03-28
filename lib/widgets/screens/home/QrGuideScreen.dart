import 'package:flutter/material.dart';
import 'package:fx_tutor/widgets/screens/home/casio_qr_guide.dart';
import 'package:fx_tutor/widgets/screens/home/pdf_viewer.dart';

class QrGuideScreen extends StatelessWidget {
  const QrGuideScreen({super.key});

  static const String route = 'QrGuideScreen';
  Widget _listAllGuides(BuildContext context) {
    // Gom toàn bộ danh sách file và tiêu đề vô một mảng chung
    final List<Map<String, String>> guides = [
      // Nhóm X1
      {'title': 'Phép tính số học', 'path': 'assets/pdf/X1_1.pdf'},
      {'title': 'Phép tính phân số', 'path': 'assets/pdf/X1_2.pdf'},
      {'title': 'Lũy thừa, căn, nghịch đảo', 'path': 'assets/pdf/X1_3.pdf'},
      {'title': 'Số Pi, cơ số lôgarit tự nhiên e', 'path': 'assets/pdf/X1_4.pdf'},
      {'title': 'Lịch sử và hiển thị lại phép tính', 'path': 'assets/pdf/X1_5.pdf'},
      {'title': 'Sử dụng chức năng bộ nhớ', 'path': 'assets/pdf/X1_6.pdf'},
      {'title': 'Sử dụng CALC', 'path': 'assets/pdf/X1_7.pdf'},

      // Nhóm các chức năng X khác
      {'title': 'HDSD Hệ đếm cơ số N', 'path': 'assets/pdf/X2.pdf'},
      {'title': 'HDSD Thống kê', 'path': 'assets/pdf/X3.pdf'},
      {'title': 'HDSD Số phức', 'path': 'assets/pdf/X4.pdf'},
      {'title': 'HDSD Phương trình', 'path': 'assets/pdf/X5.pdf'},
      {'title': 'HDSD Ma trận', 'path': 'assets/pdf/X6.pdf'},
      {'title': 'HDSD Véc-tơ', 'path': 'assets/pdf/X7.pdf'},
      {'title': 'HDSD Bảng giá trị', 'path': 'assets/pdf/X8.pdf'},
      {'title': 'HDSD Tỉ lệ thức', 'path': 'assets/pdf/XA.pdf'},
      {'title': 'HDSD Bất phương trình', 'path': 'assets/pdf/XB.pdf'},
      {'title': 'HDSD Phân phối', 'path': 'assets/pdf/XC.pdf'},
      {'title': 'HDSD Bảng tính', 'path': 'assets/pdf/XD.pdf'},
      {'title': 'HDSD Hộp toán học', 'path': 'assets/pdf/XF.pdf'},

      // Nhóm lỗi Y (dùng chung 1 file Y.pdf)
      {'title': 'Lỗi và cách xử lý', 'path': 'assets/pdf/Y.pdf'},

      // Nhóm Z
      {'title': 'HDSD Trình cài đặt', 'path': 'assets/pdf/Z0.pdf'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // Dùng map để tự động tạo ra toàn bộ thẻ (Card) từ danh sách trên
      children: guides.map((guide) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.redAccent,
                size: 32,
              ),
              title: Text(
                guide['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),

              onTap: () {
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssetPdfViewerScreen(
                        assetPath: guide['path']!,
                        title: guide['title']!,
                      ),
                    ),
                  );
                } catch (e) {
                  debugPrint("Lỗi khi mở PDF: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không thể mở file tài liệu này! Lỗi: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            // Phần nút Quét mã QR to bản
            SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Đẩy màn hình quét QR vào Nav con của Tab này
                    // Lưu ý: Đảm bảo 'CasioQr' (hoặc CasioQr.route) đã được khai báo trong mainRoute
                    Navigator.pushNamed(context, CasioQrGuide.route);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: colorScheme.onPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quét mã QR Casio",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Quét mã từ máy tính Casio để xem biểu thức toán, phương trình và đồ thị.",
                                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Tiêu đề danh sách HDSD
            SliverToBoxAdapter(
              child: Text(
                "Danh sách Hướng dẫn sử dụng",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: _listAllGuides(context),
            ),
          ],
        ),
      ),
    );
  }
}
