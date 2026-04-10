import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ai_quiz_model.dart';
import '../models/calculator_guide_model.dart';
import '../models/learning_content.dart';

class AiChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GenerativeModel _chatModel;
  final GenerativeModel _embeddingModel;

  AiChatService()
    : _chatModel = GenerativeModel(
        model: 'gemma-3-27b-it',
        apiKey: dotenv.env['API_KEY'] ?? '',
      ),
      _embeddingModel = GenerativeModel(
        model: 'gemini-embedding-001',
        apiKey: dotenv.env['API_KEY'] ?? '',
      );

  // 1. BỎ tham số required userModel
  Future<CalculatorGuideModel?> getGuide({
    String? textInput,
    Uint8List? imageBytes,
  }) async {
    try {
      final analysis = await _identifyTopicAndModel(textInput, imageBytes);
      final specificProblem = analysis['problem'] ?? '';
      final topicName = analysis['topic'] ?? '';

      if (topicName.isEmpty) {
        return null;
      } else {
        // SỬA Ở ĐÂY: Thêm chữ "return" thay vì "final guide ="
        return await _searchSupabaseForGuide(specificProblem);
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> solveAndGuide({
    String? textInput,
    Uint8List? imageBytes,
  }) async {
    try {
      // BƯỚC 1: Xác định Topic VÀ Dòng máy từ Input
      final analysis = await _identifyTopicAndModel(textInput, imageBytes);
      print("analysis: $analysis ");
      final topicName = analysis['topic'] ?? '';
      final specificProblem = analysis['problem'] ?? '';
      // Lấy model máy mà AI đoán được (có thể là null hoặc rỗng)
      final detectedModel = analysis['device'];
      if (topicName.isEmpty) {
        return "Không xác định được dạng toán. Vui lòng thử lại.";
      }

      // BƯỚC 2: Vector Search tìm hướng dẫn trong DB
      final guide = await _searchSupabaseForGuide(specificProblem);
      print("guide: $guide ");
      // BƯỚC 3: Tạo câu trả lời cuối cùng
      return await _generateFinalResponse(
        userProblem: specificProblem,
        topicFound: topicName,
        guide: guide,
        detectedModel: detectedModel, // Truyền model đã detect vào
      );
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  // Đổi tên hàm cho đúng ngữ nghĩa
  Future<Map<String, String?>> _identifyTopicAndModel(String? text, Uint8List? image) async {
    // SỬA PROMPT: Yêu cầu trích xuất thêm 'device'
    final promptText = """
    Phân tích đầu vào và trả về JSON thuần (không markdown) với các trường:
    - 'topic': Tên chủ đề chung (Tính năng hệ thống, Giải phương trình bậc 2, Tích phân...).
    - 'problem': Đề bài hoặc vấn đề cụ thể.
    - 'device': Tên dòng máy tính nếu người dùng nhắc đến (VD: 580, 880, Vinacal). Nếu không nhắc đến, trả về null.
    """;

    final content = [
      if (image != null) Content.multi([TextPart(promptText), DataPart('image/jpeg', image)]),
      if (text != null) Content.text("$promptText\nUser Input: $text"),
    ];
    final response = await _chatModel.generateContent(content);
    try {
      String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      // Xử lý sơ bộ nếu AI trả về kèm text thừa
      if (cleanJson.contains('{') && cleanJson.contains('}')) {
        cleanJson = cleanJson.substring(
          cleanJson.indexOf('{'),
          cleanJson.lastIndexOf('}') + 1,
        );
      }

      final data = jsonDecode(cleanJson);

      return {
        "topic": data['topic']?.toString(),
        "problem": data['problem']?.toString(),
        "device": data['device']?.toString(), // Lấy thông tin máy
      };
    } catch (e) {
      // Fallback nếu lỗi parse JSON
      return {"topic": response.text ?? "Toán học chung", "problem": text ?? "", "device": null};
    }
  }

  Future<CalculatorGuideModel?> _searchSupabaseForGuide(String topicName) async {
    try {
      final embeddingRes = await _embeddingModel.embedContent(Content.text(topicName));
      final vector = embeddingRes.embedding.values;

      final List<dynamic> res = await _supabase.rpc(
        'match_guides',
        params: {'query_embedding': vector, 'match_threshold': 0.65, 'match_count': 1},
      );

      if (res.isNotEmpty) return CalculatorGuideModel.fromJson(res.first);
      return null;
    } catch (e) {
      print("Lỗi search Supabase: $e");
      return null;
    }
  }

  Future<String> _generateFinalResponse({
    required String userProblem,
    required String topicFound,
    CalculatorGuideModel? guide,
    String? detectedModel,
  }) async {
    final buffer = StringBuffer();

    // ==========================================
    // 1. RÀNG BUỘC TỐI CAO (SYSTEM PROMPT)
    // ==========================================
    buffer.writeln(
      r'''Bạn là một Gia sư Toán học AI và Bậc thầy Casio, giả sử người dùng có kiến thức từ lớp 6. Nhiệm vụ của bạn là giải toán và BẮT BUỘC TRẢ VỀ DUY NHẤT MỘT MẢNG JSON hợp lệ.

⚠️ QUY TẮC ĐỊNH DẠNG JSON:
- TUYỆT ĐỐI KHÔNG bọc bằng ```json. Chỉ trả về mảng bắt đầu bằng [ và kết thúc bằng ].
- Cấu trúc mỗi phần tử bắt buộc phải có dạng: {"type": "...", "data": "..."}
- Các type được phép dùng: "text", "latex", "580keylog", "880keylog".

⚠️ QUY TẮC NỘI DUNG TỪNG KHỐI (QUAN TRỌNG):
- Khối "text": Chứa văn bản giải thích dạng TEXT THUẦN TÚY (Plain Text). 
  + TUYỆT ĐỐI KHÔNG dùng bất kỳ định dạng Markdown nào (KHÔNG in đậm **, KHÔNG in nghiêng *, KHÔNG gạch đầu dòng -, *, +, KHÔNG tạo danh sách 1. 2. 3.).
  + Viết thành các đoạn văn bình thường. Nếu cần liệt kê, hãy viết: "Bước 1: ... Bước 2: ..." (viết liền mạch hoặc chỉ xuống dòng \n).
  + TUYỆT ĐỐI KHÔNG DÙNG mã LaTeX (như \sqrt, \pm, \frac, ^2) trong khối này. Hãy dùng ký tự phổ thông (như √, ±, x²).
- Khối "latex": ĐỂ CHỨA CÔNG THỨC TOÁN. Bất cứ khi nào có phương trình, biểu thức phức tạp, hãy TÁCH RIÊNG nó thành khối "latex" độc lập.
- Khối "*keylog": Các phím BẮT BUỘC nằm trong ngoặc vuông (VD: [MENU][9]).

💡 Ví dụ cách bạn TRẢ LỜI ĐÚNG:
[
  {"type": "text", "data": "Để giải phương trình x² = 3, ta làm theo các bước sau.\nBước 1: Lấy căn bậc hai hai vế của phương trình."},
  {"type": "latex", "data": "x = \\pm \\sqrt{3}"},
  {"type": "580keylog", "data": "[ALPHA][*][2][4][SHIFT][)](,)[3][6][)][=]"},
  {"type": "text", "data": "Bước 2: Rút ra kết luận. Vậy phương trình có 2 nghiệm phân biệt."}
]
''',
    );

    // ==========================================
    // 2. NGỮ CẢNH BÀI TOÁN CỦA USER
    // ==========================================
    buffer.writeln("\n--- THÔNG TIN BÀI TOÁN ---");
    buffer.writeln("Đề bài: '$userProblem'");
    buffer.writeln("Dạng toán: $topicFound");

    // ==========================================
    // 3. LOGIC RẼ NHÁNH: XỬ LÝ HƯỚNG DẪN & MÁY TÍNH
    // ==========================================
    if (guide != null) {
      buffer.writeln("\n--- DỮ LIỆU HƯỚNG DẪN BẤM MÁY (TỪ DB) ---");
      buffer.writeln(
        "Chi tiết cách bấm tổng quát: ${jsonEncode(guide.methods.map((e) => e.toJson()).toList())}, máy hõ trợ ${jsonEncode(guide.compatibleModels.toString())} ",
      );
      print(
        "Chi tiết cách bấm tổng quát: ${jsonEncode(guide.methods.map((e) => e.toJson()).toList())}, máy hõ trợ ${jsonEncode(guide.compatibleModels.toString())} ",
      );
      buffer.writeln("\n--- YÊU CẦU XỬ LÝ ---");
      buffer.writeln(
        "1. Hãy giải tay chi tiết bài toán trên, sau đó áp dụng hệ số vào hướng dẫn bấm máy.",
      );

      // Xử lý logic Model
      bool hasSpecificModel =
          detectedModel != null &&
          detectedModel.toLowerCase() != 'null' &&
          detectedModel.trim().isNotEmpty;

      if (hasSpecificModel) {
        buffer.writeln(
          "2. LƯU Ý QUAN TRỌNG: Người dùng CHỈ quan tâm đến dòng máy '$detectedModel'.",
        );
        buffer.writeln(
          " -> BẠN CHỈ ĐƯỢC PHÉP tạo khối keylog cho dòng máy '$detectedModel' (Ví dụ: chỉ tạo type '580keylog' nếu user hỏi 580).",
        );
        buffer.writeln(
          " -> Bỏ qua phần hướng dẫn của các máy khác để tránh làm rối người dùng. Nếu DB không có máy này, hãy tạo khối 'text' thông báo không hỗ trợ và đưa ra cách bấm của máy có sẵn.",
        );
      } else {
        buffer.writeln("2. LƯU Ý QUAN TRỌNG: Người dùng KHÔNG chỉ định máy tính cụ thể.");
        buffer.writeln(
          " -> BẠN PHẢI tạo đầy đủ các khối keylog cho TẤT CẢ các dòng máy: máy hỗ trợ ${jsonEncode(guide.compatibleModels.toString())}  ( nếu có 2 máy thì '580keylog' và '880keylog' tách biệt nhau).",
        );
      }
    } else {
      buffer.writeln("\n--- YÊU CẦU XỬ LÝ ---");
      buffer.writeln("1. KHÔNG CÓ hướng dẫn bấm máy cho dạng này trong DB.");
      buffer.writeln("2. Bạn chỉ cần giải tay từng bước, sử dụng type 'text' và 'latex'.");
      buffer.writeln(
        "3. TUYỆT ĐỐI KHÔNG TẠO ra các khối type '580keylog' hay '880keylog' trong trường hợp này.",
      );
    }

    // ==========================================
    // 4. CALL API
    // ==========================================
    final prompt = buffer.toString();

    try {
      final response = await _chatModel.generateContent([Content.text(prompt)]);

      // Clean response để chống AI nhả thêm rác markdown
      String finalData = response.text ?? "";

      // SỬA LỖI: Cắt đúng thẻ markdown ```json và ```
      finalData = finalData.replaceAll('```json', '').replaceAll('```', '').trim();

      // BẢO HIỂM LỚP 2: Nếu AI vẫn vui tính chèn thêm text bên ngoài mảng JSON
      if (finalData.contains('[') && finalData.contains(']')) {
        finalData = finalData.substring(
          finalData.indexOf('['),
          finalData.lastIndexOf(']') + 1,
        );
      }

      return finalData;
    } catch (e) {
      return "Lỗi khi gọi AI: $e";
    }
  }

  Future<List<AiQuizModel>> generateQuiz(LearningContent content) async {
    final prompt =
        """
    Dựa trên nội dung học tập dưới đây, hãy tạo 5 câu hỏi trắc nghiệm toán học, chủ yếu bấm máy tính.
    Yêu cầu:
    - Mỗi câu hỏi có 4 lựa chọn.
    - không dùng latex, dùng kí hiệu thông thường dễ hiểu
    - Trả về kết quả dưới dạng một danh sách JSON thuần (không markdown).
    - Mỗi đối tượng trong danh sách phải có các trường: 
      "question": (String),
      "options": (List of 4 Strings),
      "correct_answer_index": (int, từ 0 đến 3),
      "explanation": (String, giải thích ngắn gọn lý do chọn đáp án đó, gợi ý bấm máy nếu nội dung có đề cập, không thì thôi).

    Nội dung học tập:
    Tiêu đề: ${content.title}
    Nội dung chi tiết: ${content.blocks.map((b) => b.data ?? "").join("\n")}
    """;

    try {
      final response = await _chatModel.generateContent([Content.text(prompt)]);
      String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      if (cleanJson.contains('[') && cleanJson.contains(']')) {
        cleanJson = cleanJson.substring(
          cleanJson.indexOf('['),
          cleanJson.lastIndexOf(']') + 1,
        );
      }

      final List<dynamic> data = jsonDecode(cleanJson);
      return data.map((item) => AiQuizModel.fromJson(item)).toList();
    } catch (e) {
      print("Lỗi generate quiz: $e");
      return [];
    }
  }

  // --- HÀM MỚI: TẠO MÃ LATEX ---
  Future<String> convertToLatex(String input) async {
    final prompt =
        """
    Bạn là một trình biên dịch sang LaTeX.
    Nhiệm vụ: Chuyển đổi biểu thức toán học hoặc mô tả bằng lời văn dưới đây thành mã LaTeX chuẩn xác.
    
    YÊU CẦU NGHIÊM NGẶT:
    - CHỈ trả về đúng đoạn mã LaTeX.
    - KHÔNG bọc trong block code markdown (tức là không dùng ```latex và ```).
    - KHÔNG thêm bất kỳ câu chào hỏi, giải thích hay văn bản thừa nào.
    - KHÔNG sử dụng dấu \$ ở đầu và cuối (chỉ trả về phần lõi công thức).
    
    Đầu vào: "$input"
    """;

    try {
      final response = await _chatModel.generateContent([Content.text(prompt)]);
      String latexCode = response.text ?? "";

      // Cleanup phòng hờ trường hợp AI vẫn ngoan cố bọc markdown
      latexCode = latexCode.replaceAll('```latex', '').replaceAll('```', '').trim();

      return latexCode;
    } catch (e) {
      print("Lỗi chuyển đổi LaTeX: $e");
      return "Lỗi hệ thống khi tạo LaTeX.";
    }
  }
}
