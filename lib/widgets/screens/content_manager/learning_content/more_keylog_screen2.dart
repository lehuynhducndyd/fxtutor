import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoreKeylogScreen2 extends StatefulWidget {
  static const String route = 'MoreKeylogScreen2';

  const MoreKeylogScreen2({super.key});

  @override
  State<MoreKeylogScreen2> createState() => _MoreKeylogScreen2State();
}

class _MoreKeylogScreen2State extends State<MoreKeylogScreen2> {
  late Future<Map<String, String>> _mappingDataFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm load dữ liệu 1 lần duy nhất ở initState để tối ưu hiệu năng
    _mappingDataFuture = _loadMappingData();
  }

  // Hàm đọc dữ liệu từ file JSON trong thư mục assets
  Future<Map<String, String>> _loadMappingData() async {
    final String response = await rootBundle.loadString('assets/keymap/other580.json');
    final Map<String, dynamic> data = jsonDecode(response);
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Casio fx-580VNX Keylog', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Lời nhắc nhẹ cho người dùng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: colorScheme.primaryContainer.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Chạm vào thẻ bất kỳ để sao chép mã",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Lưới hiển thị Keylog
          Expanded(
            child: FutureBuilder<Map<String, String>>(
              future: _mappingDataFuture,
              builder: (context, snapshot) {
                // Trạng thái đang tải
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Trạng thái lỗi
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi tải dữ liệu: ${snapshot.error}',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  );
                }
                // Trạng thái không có dữ liệu
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có dữ liệu mapping.',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  );
                }

                // Trạng thái tải thành công
                final entries = snapshot.data!.entries.toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160.0,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.9, // Thẻ hơi cao lên một chút cho cân đối
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final keyString = entries[index].key;
                    final valueString = entries[index].value;

                    return Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Copy vào bộ nhớ tạm
                          Clipboard.setData(ClipboardData(text: keyString));

                          // Hiển thị thông báo M3 mượt mà
                          ScaffoldMessenger.of(
                            context,
                          ).clearSnackBars(); // Xóa thông báo cũ nếu bấm liên tục
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('Đã sao chép: $keyString')),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(milliseconds: 1500),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Ký tự nút bấm máy tính (Font Casio580)
                                  Expanded(
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'Casio580', // Đúng font 580
                                            fontSize: 32, // Phóng to font phím bấm
                                            color: colorScheme.onSurface,
                                          ),
                                          children: [
                                            TextSpan(text: valueString),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Mã Key (Dùng để soạn thảo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      keyString,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Icon copy mờ ở góc thẻ
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
