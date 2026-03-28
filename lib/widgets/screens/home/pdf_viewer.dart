import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AssetPdfViewerScreen extends StatelessWidget {
  final String assetPath;
  final String title;

  const AssetPdfViewerScreen({
    super.key,
    required this.assetPath,
    this.title = "Tài liệu HDSD",
  });

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình để kiểm tra xem đang xài phone hay tablet
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Đổi màu nền ngoài cùng thành xám nhạt để làm nổi khung PDF bên trong
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
      ),
      // Bọc vô Center để canh giữa
      body: Center(
        // Giới hạn chiều ngang tối đa (khoảng 800 là đẹp cho tablet)
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: Container(
            // Nếu màn hình bự hơn 800 (tablet), đánh thêm cái bóng đổ nhìn cho nghệ
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: screenWidth > 800
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null, // Trên điện thoại thì khỏi cần bóng
            ),
            child: SfPdfViewer.asset(
              assetPath,
              canShowScrollHead: false,
              canShowScrollStatus: true,
            ),
          ),
        ),
      ),
    );
  }
}
