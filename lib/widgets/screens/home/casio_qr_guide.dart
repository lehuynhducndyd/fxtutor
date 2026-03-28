import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:fx_tutor/services/translate.dart';
import 'package:fx_tutor/widgets/screens/home/pdf_viewer.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../services/qr_parse_service.dart';

class CasioQrGuide extends StatefulWidget {
  const CasioQrGuide({super.key});
  static const String route = 'CasioQrGuide';

  @override
  State<CasioQrGuide> createState() => _CasioQrGuideState();
}

class _CasioQrGuideState extends State<CasioQrGuide> {
  Map<String, dynamic> _qrContent = {};
  String rawLink = "";
  String modeCode = "";

  late CasioQRParser _parser;
  bool _isParserReady = false;

  @override
  void initState() {
    super.initState();
    _parser = CasioQRParser();
    _initParser();
  }

  Future<void> _initParser() async {
    await _parser.initEngine();
    if (mounted) {
      setState(() {
        _isParserReady = true;
      });
    }
  }

  @override
  void dispose() {
    _parser.dispose();
    super.dispose();
  }

  String _getCSVString() {
    String csvString = '';

    if (_qrContent['statistic'] != null) {
      csvString = _qrContent['statistic']['csv'];
    }
    if (_qrContent['spreadsheet'] != null) {
      csvString = _qrContent['spreadsheet']['csv'];
    }
    return csvString;
  }

  String _getEquationLatex() {
    if (_qrContent['equation'] != null && _qrContent['equation'] is Map) {
      String rawLatex = _qrContent['equation']['latex'] ?? '';
      if (rawLatex.isEmpty) return '';

      // Xử lý chống crash và giãn dòng
      if (rawLatex.contains('\\\\left') || rawLatex.contains('\\\\begin')) {
        rawLatex = rawLatex.replaceAll('\\\\\\\\', '__NL__');
        rawLatex = rawLatex.replaceAll('\\\\', '\\');
        rawLatex = rawLatex.replaceAll('__NL__', '\\\\ \\\\[10pt]');
      } else {
        rawLatex = rawLatex.replaceAll(r'\\', r'\\[15pt]');
      }

      if (!rawLatex.contains('\\begin{')) {
        return '\\begin{array}{l} $rawLatex \\end{array}';
      }

      return rawLatex;
    } else {
      return '';
    }
  }

  String _getdistributionLatex() {
    if (_qrContent['distribution'] != null && _qrContent['distribution'] is Map) {
      String rawLatex = _qrContent['distribution']['latex'] ?? '';
      if (rawLatex.isEmpty) return '';

      // Xử lý chống crash và giãn dòng
      if (rawLatex.contains('\\\\left') || rawLatex.contains('\\\\begin')) {
        rawLatex = rawLatex.replaceAll('\\\\\\\\', '__NL__');
        rawLatex = rawLatex.replaceAll('\\\\', '\\');
        rawLatex = rawLatex.replaceAll('__NL__', '\\\\ \\\\[10pt]');
      } else {
        rawLatex = rawLatex.replaceAll(r'\\', r'\\[15pt]');
      }

      if (!rawLatex.contains('\\begin{')) {
        return '\\begin{array}{l} $rawLatex \\end{array}';
      }

      return rawLatex;
    } else {
      return '';
    }
  }

  String _getName() {
    if (_qrContent['mode'] != null && _qrContent['mode'] is Map) {
      String mainName = CasioTranslator.translate(_qrContent['mode']['mainName']) ?? '';
      String subName = '';
      if (_qrContent['mode']['subName'] != null) {
        String subName = CasioTranslator.translate(_qrContent['mode']['subName']) ?? '';
        if (subName.isNotEmpty) subName = ' - $subName';
      }
      return '$mainName$subName';
    } else {
      return '';
    }
  }

  String _getMode() {
    if (_qrContent['mode'] != null && _qrContent['mode'] is Map) {
      String mainMode = CasioTranslator.translate(_qrContent['mode']['mainMode']) ?? '';
      return mainMode;
    } else {
      return '';
    }
  }

  List<String> _getFunctionLatex() {
    List<String> functionList = [];

    // Kiểm tra xem 'function' có tồn tại và là một mảng (List) hay không
    if (_qrContent['function'] != null && _qrContent['function'] is List) {
      for (var func in _qrContent['function']) {
        String name = func['name']?.toString() ?? '';
        String expression = func['expression']?.toString() ?? 'undefine';

        // Nếu cả hai đều rỗng thì bỏ qua mảnh này
        if (name.isEmpty && expression.isEmpty) continue;

        // Ghép thành chuỗi chuẩn LaTeX (VD: f(x) = 1)
        String rawLatex = "$name=$expression";

        // --- ÁP DỤNG BỘ LỌC CHỐNG CRASH & GIÃN DÒNG ---
        if (rawLatex.contains('\\\\left') || rawLatex.contains('\\\\begin')) {
          rawLatex = rawLatex.replaceAll('\\\\\\\\', '__NL__');
          rawLatex = rawLatex.replaceAll('\\\\', '\\');
          rawLatex = rawLatex.replaceAll('__NL__', '\\\\ \\\\[10pt]');
        } else {
          rawLatex = rawLatex.replaceAll(r'\\', r'\\[15pt]');
        }

        // Bọc môi trường array để đảm bảo flutter_math_fork render an toàn
        if (!rawLatex.contains('\\begin{')) {
          rawLatex = '\\begin{array}{l} $rawLatex \\end{array}';
        }

        functionList.add(rawLatex);
      }
    }

    return functionList;
  }

  List<String> _getMatrixLatex() {
    List<String> matrixList = [];

    // Kiểm tra xem 'matrix' có tồn tại và là một mảng (List) hay không
    if (_qrContent['matrix'] != null && _qrContent['matrix'] is List) {
      for (var mat in _qrContent['matrix']) {
        String name = mat['name']?.toString() ?? '';
        String rawLatex = mat['latex']?.toString() ?? '';

        if (name.isEmpty && rawLatex.isEmpty) continue;

        // Ghép tên và ma trận (VD: MatC = \begin{bmatrix}...)
        String combinedLatex = '$name=$rawLatex';

        // --- ÁP DỤNG BỘ LỌC CHỐNG CRASH & GIÃN DÒNG ---
        if (combinedLatex.contains('\\\\left') || combinedLatex.contains('\\\\begin')) {
          // Cất giấu 4 gạch chéo (xuống dòng của ma trận)
          combinedLatex = combinedLatex.replaceAll('\\\\\\\\', '__NL__');
          // Gọt 2 gạch chéo thành 1 gạch chéo
          combinedLatex = combinedLatex.replaceAll('\\\\', '\\');
          // Trả lại lệnh xuống dòng.
          // Ma trận không cần giãn quá rộng như phân số, nên cộng thêm 5pt-8pt là đẹp
          combinedLatex = combinedLatex.replaceAll('__NL__', '\\\\ \\\\[5pt]');
        } else {
          combinedLatex = combinedLatex.replaceAll(r'\\', r'\\[5pt]');
        }

        matrixList.add(combinedLatex);
      }
    }

    return matrixList;
  }

  List<String> _getVectorLatex() {
    List<String> matrixList = [];

    // Kiểm tra xem 'matrix' có tồn tại và là một mảng (List) hay không
    if (_qrContent['vector'] != null && _qrContent['vector'] is List) {
      for (var mat in _qrContent['vector']) {
        String name = mat['name']?.toString() ?? '';
        String rawLatex = mat['latex']?.toString() ?? '';

        if (name.isEmpty && rawLatex.isEmpty) continue;

        // Ghép tên và ma trận (VD: MatC = \begin{bmatrix}...)
        String combinedLatex = '$name=$rawLatex';

        // --- ÁP DỤNG BỘ LỌC CHỐNG CRASH & GIÃN DÒNG ---
        if (combinedLatex.contains('\\\\left') || combinedLatex.contains('\\\\begin')) {
          // Cất giấu 4 gạch chéo (xuống dòng của ma trận)
          combinedLatex = combinedLatex.replaceAll('\\\\\\\\', '__NL__');
          // Gọt 2 gạch chéo thành 1 gạch chéo
          combinedLatex = combinedLatex.replaceAll('\\\\', '\\');
          // Trả lại lệnh xuống dòng.
          // Ma trận không cần giãn quá rộng như phân số, nên cộng thêm 5pt-8pt là đẹp
          combinedLatex = combinedLatex.replaceAll('__NL__', '\\\\ \\\\[5pt]');
        } else {
          combinedLatex = combinedLatex.replaceAll(r'\\', r'\\[5pt]');
        }

        matrixList.add(combinedLatex);
      }
    }

    return matrixList;
  }

  String _getResultLatex() {
    if (_qrContent['result'] != null && _qrContent['result'] is List) {
      for (var item in _qrContent['result']) {
        String name = item['name']?.toString() ?? '';
        String rawLatex = item['latex']?.toString() ?? '';

        // Bỏ qua nếu rỗng hoặc là các mảnh cắt nhỏ (Part1, Part2...)
        if (rawLatex.isEmpty || name.startsWith('Part')) continue;

        String finalLatex = rawLatex;

        // Nếu là MatAns hay tên khác (không phải 'templated'), ghép thêm tên vào
        if (name != 'templated' && name.isNotEmpty) {
          finalLatex = "$name=$rawLatex";
        }

        // --- BỘ LỌC CHỐNG CRASH & GIÃN DÒNG ---
        if (finalLatex.contains('\\\\left') || finalLatex.contains('\\\\begin')) {
          finalLatex = finalLatex.replaceAll('\\\\\\\\', '__NL__');
          finalLatex = finalLatex.replaceAll('\\\\', '\\');
          finalLatex = finalLatex.replaceAll('__NL__', '\\\\ \\\\[5pt]');
        } else {
          finalLatex = finalLatex.replaceAll(r'\\', r'\\[5pt]');
        }

        // Bọc môi trường array
        if (!finalLatex.contains('\\begin{')) {
          finalLatex = '\\begin{array}{l} $finalLatex \\end{array}';
        }

        // LƯU Ý: Lấy được cái đầu tiên là 'chốt đơn' trả về luôn, không lặp nữa
        return finalLatex;
      }
    }

    return ''; // Nếu không có gì thì trả về chuỗi rỗng
  }

  Widget _buildTable(String title, String csvstring, BuildContext context) {
    if (csvstring.isEmpty) return const SizedBox.shrink();

    // 1. Phân tích chuỗi CSV ngay trong hàm
    List<String> rows = csvstring.trim().split('\n');
    List<List<String>> tableData = rows.map((row) => row.split(',')).toList();

    // Gọt bỏ các dòng rỗng (chứa toàn dấu phẩy như ",,,,")
    tableData.removeWhere((row) => row.every((cell) => cell.trim().isEmpty));

    if (tableData.isEmpty || tableData[0].isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ================= TIÊU ĐỀ & NÚT XUẤT FILE =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                try {
                  // 1. Chuyển chuỗi CSV sang định dạng byte (UTF-8)
                  final bytes = Uint8List.fromList(utf8.encode(csvstring));

                  // 2. Gọi lệnh "Save As" để ÉP hệ điều hành hiện hộp thoại chọn thư mục
                  String? filePath = await FileSaver.instance.saveAs(
                    name: 'casio_data_${DateTime.now().millisecondsSinceEpoch}',
                    bytes: bytes, // Nếu IDE vẫn báo lỗi đỏ thì thêm 'as dynamic' vô lại nha
                    mimeType: MimeType.csv,
                    fileExtension: 'csv',
                  );

                  // 3. Thông báo thành công
                  // LƯU Ý: Check filePath != null vì người dùng có thể bấm "Hủy/Cancel" lúc chọn thư mục
                  if (context.mounted && filePath != null && filePath.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã lưu tại: $filePath'), // In luôn đường dẫn ra cho dễ tìm
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi lưu file: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("Lưu CSV"),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ================= GIAO DIỆN BẢNG DATATABLE =================
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias, // Bo góc mượt mà cho bảng
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Cuộn ngang nếu cột quá dài
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ),
                columns: List.generate(
                  tableData[0].length,
                  (index) => DataColumn(
                    label: Text(
                      // Tự động đánh tên cột: A, B, C, D...
                      String.fromCharCode(65 + index),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                rows: tableData.map((row) {
                  return DataRow(
                    cells: row.map((cell) {
                      final cellText = cell.trim();
                      return DataCell(
                        Text(
                          cellText.isEmpty ? '-' : cellText, // Ô rỗng thì để dấu trừ cho đỡ trống
                          style: TextStyle(
                            color: cellText.isEmpty ? colorScheme.outline : colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLatexSection(String title, String latexCode, BuildContext context) {
    if (latexCode.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                latexCode,
                mathStyle: MathStyle.display,
                textStyle: const TextStyle(fontSize: 18),
                onErrorFallback: (FlutterMathException e) {
                  return Text(
                    "Lỗi hiển thị: ${e.message}",
                    style: TextStyle(color: colorScheme.error),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String getPdfPath(String mode) {
    switch (mode) {
      case 'X1':
        return 'assets/pdf/X1.pdf';
      case 'X2':
        return 'assets/pdf/X2.pdf';
      case 'X3':
        return 'assets/pdf/X3.pdf';
      case 'X4':
        return 'assets/pdf/X4.pdf';
      case 'X5':
        return 'assets/pdf/X5.pdf';
      case 'X6':
        return 'assets/pdf/X6.pdf';
      case 'X7':
        return 'assets/pdf/X7.pdf';
      case 'X8':
        return 'assets/pdf/X8.pdf';
      case 'XA':
        return 'assets/pdf/XA.pdf';
      case 'XB':
        return 'assets/pdf/XB.pdf';
      case 'XC':
        return 'assets/pdf/XC.pdf';
      case 'XD':
        return 'assets/pdf/XD.pdf';
      case 'XE':
        return 'assets/pdf/XE.pdf';
      case 'XF':
        return 'assets/pdf/XF.pdf';
      case 'Z0':
      case 'Z1':
        return 'assets/pdf/Z0.pdf';
      case 'Y1':
      case 'Y2':
      case 'Y3':
      case 'Y4':
      case 'Y5':
      case 'Y6':
      case 'Y7':
      case 'Y8':
      case 'Y9':
      case 'YA':
      case 'YB':
      case 'YC':
      case 'YD':
      case 'YE':
      case 'YF':
      case 'YG':
      case 'YH':
      case 'YZ':
        return 'assets/pdf/Y.pdf';
      default:
        return '';
    }
  }

  Widget _listGuideX1(BuildContext context) {
    // Tạo danh sách cấu hình gồm tên (dummy) và đường dẫn file
    final List<Map<String, String>> guides = [
      {'title': 'Phép tính số học', 'path': 'assets/pdf/X1_1.pdf'},
      {'title': 'Phép tính phân số', 'path': 'assets/pdf/X1_2.pdf'},
      {'title': 'Lũy thừa, căn, nghịch đảo', 'path': 'assets/pdf/X1_3.pdf'},
      {'title': 'Số Pi, cơ số lôgarit tự nhiên e', 'path': 'assets/pdf/X1_4.pdf'},
      {'title': 'Lịch sử và hiển thị lại phép tính', 'path': 'assets/pdf/X1_5.pdf'},
      {'title': 'Sử dụng chức năng bộ nhớ', 'path': 'assets/pdf/X1_6.pdf'},
      {'title': 'Sử dụng CALC', 'path': 'assets/pdf/X1_7.pdf'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // Dùng map để tự động tạo ra 7 cái thẻ (Card)
      children: guides.map((guide) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0), // Khoảng cách giữa các thẻ
          child: Card(
            elevation: 2, // Đổ bóng nhẹ cho đẹp
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),

              // Thay onPressed bằng onTap của ListTile
              onTap: () {
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssetPdfViewerScreen(
                        assetPath: guide['path']!,
                        title: guide['title']!, // Truyền luôn tên qua màn hình PDF nếu cần
                      ),
                    ),
                  );
                } catch (e) {
                  debugPrint("Lỗi khi mở PDF: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể mở file: $e')),
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
    String expression = _qrContent['expression'] ?? '';
    String equation = _getEquationLatex();
    List<String> functions = _getFunctionLatex();
    List<String> matrices = _getMatrixLatex();
    String result = _getResultLatex();
    List<String> vectors = _getVectorLatex();
    String csvString = _getCSVString();
    String distribution = _getdistributionLatex();
    String name = _getName();
    String mode = _getMode();
    String assetPath = "";
    assetPath = getPdfPath(mode);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Quét mã QR Casio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isParserReady)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_isParserReady && _qrContent.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 80,
                        color: colorScheme.outline.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Bấm nút Quét QR bên dưới để giải mã biểu thức từ máy tính Casio fx-880BTG",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Đối với QR phân mảnh (dữ liệu dài) cần thực hiện quét nhiều lần.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            (name.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 18),
                    ),
                  )
                : const SizedBox(height: 0),
            (assetPath.isNotEmpty && mode != 'X1')
                ? ElevatedButton(
                    onPressed: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetPdfViewerScreen(
                              assetPath: assetPath,
                            ),
                          ),
                        );
                      } catch (e) {
                        print("Lỗi khi mở PDF: $e");
                      }
                    },
                    child: Text("Mở hướng dẫn sử dụng"),
                  )
                : const SizedBox(height: 0),
            (mode == 'X1') ? _listGuideX1(context) : const SizedBox(height: 0),
            if (_qrContent.isNotEmpty) ...[
              if (expression.isNotEmpty)
                _buildLatexSection('Biểu thức', expression, context)
              else
                const SizedBox(height: 0),

              if (equation.isNotEmpty)
                _buildLatexSection('Phương trình', equation, context)
              else
                const SizedBox(height: 0),
              if (distribution.isNotEmpty)
                _buildLatexSection('Tham số Phân phối', distribution, context)
              else
                const SizedBox(height: 0),
              if (csvString.isNotEmpty)
                _buildTable('Bảng dữ liệu', csvString, context)
              else
                const SizedBox(height: 0),

              // TỰ ĐỘNG LẶP: Có bao nhiêu hàm số (f(x), g(x)...) in ra bấy nhiêu
              if (functions.isNotEmpty)
                ...functions.map(
                  (funcLatex) => _buildLatexSection('Hàm số', funcLatex, context),
                )
              else
                const SizedBox(height: 0),
              (functions.isNotEmpty)
                  ? ElevatedButton(
                      onPressed: () async {
                        if (rawLink.isNotEmpty) {
                          final Uri url = Uri.parse(rawLink);
                          // Dùng mode externalApplication để ép mở bằng Chrome/Safari/trình duyệt mặc định
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Không thể mở trình duyệt lúc này!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text("Xem đồ thị"),
                    )
                  : const SizedBox(height: 0),
              // TỰ ĐỘNG LẶP: Có bao nhiêu ma trận in ra bấy nhiêu
              if (matrices.isNotEmpty)
                ...matrices.map(
                  (matrixLatex) => _buildLatexSection('Ma trận', matrixLatex, context),
                )
              else
                const SizedBox(height: 0),
              if (vectors.isNotEmpty)
                ...vectors.map(
                  (vector) => _buildLatexSection('Vector', vector, context),
                )
              else
                const SizedBox(height: 0),

              Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 0),
              if (result.isNotEmpty)
                _buildLatexSection('Kết quả', result, context)
              else
                const SizedBox(height: 0),

              // BẮT LỖI QR KHÔNG HỖ TRỢ
              if (equation.isEmpty &&
                  functions.isEmpty &&
                  matrices.isEmpty &&
                  result.isEmpty &&
                  csvString.isEmpty &&
                  distribution.isEmpty &&
                  vectors.isEmpty &&
                  name.isEmpty &&
                  expression.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 80,
                          color: colorScheme.error.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không phân tích được mã QR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chế độ hiện tại trên máy tính Casio chưa được hệ thống hỗ trợ phân tích.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.outline,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 64),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_isParserReady) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );

          if (result != null && result is String) {
            final parsedData = _parser.parse(result);

            setState(() {
              _qrContent = parsedData;
              rawLink = result;
            });
          }
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text("Quét mã Casio"),
      ),
    );
  }
}

// ============================================================================
// 4. MÀN HÌNH QUÉT QR VÀ GHÉP MẢNH (STRUCTURED APPEND HACK)
// ============================================================================
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    // Dùng tốc độ normal để camera mượt, ta sẽ tự quản lý chống lặp bằng logic
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.qrCode],
  );

  // Danh sách chứa các mảnh QR quét được
  List<String> _scannedParts = [];

  // Khóa camera khi đang hiển thị thông báo
  bool _isPaused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isPaused) return; // Nếu đang khoá camera (hiện popup) thì lơ đi

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrData = barcodes.first.rawValue;
    if (qrData == null) return;

    // KIỂM TRA TRÙNG LẶP: Nếu mã QR này đã quét rồi thì lơ đi (đợi người dùng bấm sang mã kế tiếp)
    if (_scannedParts.contains(qrData)) return;

    // ĐÃ TÌM THẤY MÃ MỚI
    setState(() {
      _isPaused = true; // Lập tức khoá camera lại
      _scannedParts.add(qrData); // Lưu vào bộ nhớ
    });

    _showActionDialog();
  }

  void _showActionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng bấm nút
      // ĐỔI TÊN BIẾN NÀY THÀNH dialogContext ĐỂ KHÔNG BỊ NHẦM LẪN
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Đã nhận mã số ${_scannedParts.length}'),
            ],
          ),
          content: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: "Nếu máy tính Casio tạo nhiều mã QR, hãy bấm phím "),
                TextSpan(
                  text: "R", // Nút QR của font Casio880
                  style: const TextStyle(
                    fontFamily: 'Casio880',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text:
                      " sau đó bấm \"Quét tiếp\".\n\nNếu đã quét xong TẤT CẢ các mã QR, hãy bấm \"Hoàn tất\".",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // CHỌN QUÉT TIẾP
                Navigator.pop(dialogContext); // Đóng popup bằng dialogContext
                setState(() {
                  _isPaused = false; // Mở khoá camera để quét mã tiếp theo
                });
              },
              child: const Text('Quét tiếp'),
            ),
            FilledButton(
              onPressed: () {
                // CHỌN HOÀN TẤT
                Navigator.pop(dialogContext); // 1. Đóng popup bằng dialogContext

                // GHÉP CHUỖI VÀ GỬI VỀ
                String fullCasioData = _scannedParts.join('');
                _controller.stop(); // Tắt camera

                // 2. Đóng màn hình Quét QR bằng 'context' gốc của màn hình
                Navigator.pop(context, fullCasioData);
              },
              child: const Text('Hoàn tất & Xử lý'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: "Bấm "),
              TextSpan(
                text: "q[", // Nút QR của font Casio880
                style: const TextStyle(
                  fontFamily: 'Casio880',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: " để tạo QR"),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Camera Scnanner
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // 2. Chỉ báo số mảnh đang lưu trữ (Hiện góc trên cùng)
          if (_scannedParts.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.library_add_check_rounded,
                      color: Colors.greenAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đang lưu giữ ${_scannedParts.length} mảnh ghép...',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
