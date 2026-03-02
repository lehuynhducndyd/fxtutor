import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoreKeylogScreen2 extends StatelessWidget {
  static const String route = 'MoreKeylogScreen2';
  // Hàm đọc dữ liệu từ file JSON trong thư mục assets
  Future<Map<String, String>> loadMappingData() async {
    // Đọc file dưới dạng chuỗi
    final String response = await rootBundle.loadString('assets/keymap/other580.json');

    // Decode JSON thành Map<String, dynamic>
    final Map<String, dynamic> data = jsonDecode(response);

    // Ép kiểu thành Map<String, String> để dễ sử dụng
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casio fx-580VNX keylog'),
        centerTitle: true,
      ),
      // Sử dụng FutureBuilder để xử lý dữ liệu bất đồng bộ
      body: FutureBuilder<Map<String, String>>(
        future: loadMappingData(),
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Trạng thái lỗi
          else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          // Trạng thái không có dữ liệu
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu mapping.'));
          }

          // Trạng thái tải thành công
          final entries = snapshot.data!.entries.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
                  150.0, // Chiều rộng tối đa của 1 phần tử (bạn có thể chỉnh số này)
              crossAxisSpacing: 10.0, // Khoảng cách giữa các cột
              mainAxisSpacing: 10.0, // Khoảng cách giữa các hàng
              childAspectRatio:
                  0.85, // Tỷ lệ khung hình (chiều rộng / chiều cao). Giảm số này nếu muốn thẻ cao hơn.
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final keyString = entries[index].key;
              final valueString = entries[index].value;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Phần Key
                      Text(
                        keyString,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // 2. Phần RichText cho Value
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Casio580',
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(text: valueString),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // 3. Nút Copy nhanh
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.blue),
                        tooltip: 'Sao chép giá trị',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: keyString));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã sao chép: $keyString'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
