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
        model: 'gemini-2.5-flash',
        apiKey: dotenv.env['API_KEY'] ?? '',
      ),
      _embeddingModel = GenerativeModel(
        model: 'gemini-embedding-001',
        apiKey: dotenv.env['API_KEY'] ?? '',
      );

  // 1. BỎ tham số required userModel
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
    String? detectedModel, // Model AI tự phát hiện
  }) async {
    final buffer = StringBuffer();
    buffer.writeln("Bạn là trợ lý toán học (Gia sư AI).");
    buffer.writeln("User cần giải bài: '$userProblem' (Dạng: $topicFound).");

    // LOGIC XỬ LÝ MODEL
    if (detectedModel != null &&
        detectedModel.toLowerCase() != 'null' &&
        detectedModel.isNotEmpty) {
      buffer.writeln("Người dùng đang hỏi về máy: $detectedModel.");
    } else {
      buffer.writeln("Người dùng KHÔNG chỉ định dòng máy cụ thể.");
    }

    if (guide != null) {
      buffer.writeln("\n--- DỮ LIỆU HƯỚNG DẪN TỪ HỆ THỐNG ---");
      buffer.writeln("Các máy hỗ trợ trong DB: ${guide.compatibleModels.join(', ')}");
      // Convert list methods sang chuỗi để AI đọc
      buffer.writeln(
        "Chi tiết cách bấm: ${jsonEncode(guide.methods.map((e) => e.toJson()).toList())}",
      );

      buffer.writeln("\n--- YÊU CẦU TRẢ LỜI ---");
      buffer.writeln("1. Hãy giải bài toán '$userProblem' chi tiết.");

      // LOGIC QUAN TRỌNG: Có model hay không?
      if (detectedModel != null &&
          detectedModel.toLowerCase() != 'null' &&
          detectedModel.isNotEmpty) {
        // TRƯỜNG HỢP 1: User có nói tên máy (VD: 580)
        buffer.writeln(
          "2. Chỉ trích xuất hướng dẫn bấm máy cho dòng '$detectedModel' (hoặc dòng tương tự nhất trong DB).",
        );
        buffer.writeln("3. Nếu DB không có máy đó, hãy cảnh báo và hướng dẫn bằng máy có sẵn.");
      } else {
        // TRƯỜNG HỢP 2: User KHÔNG nói tên máy -> Hiện tất cả
        buffer.writeln(
          "2. Vì người dùng không nói rõ dùng máy nào, hãy liệt kê hướng dẫn cho TẤT CẢ các dòng máy có trong dữ liệu trên (VD: Cách bấm cho 580..., Cách bấm cho 880...).",
        );
        buffer.writeln("3. Trình bày tách biệt rõ ràng từng loại máy.");
      }

      buffer.writeln(
        "4. Các phím bấm BẮT BUỘC để trong ngoặc vuông [ ] giống như chi tiết cách bấm được cung cấp. Ví dụ: [MENU], [AC]. Trả lời ngắn gọn sát với hướng dẫn.",
      );
      buffer.writeln(
        '''5. QUY ĐỊNH TRÌNH BÀY:
    - KHÔNG sử dụng định dạng danh sách Markdown (1. 2. 3. hoặc * + -).
    - Thay vào đó, hãy viết các bước theo kiểu: Bước 1:, Bước 2:... hoặc gạch đầu dòng bằng ký tự '-' thủ công.
    - Giữ văn bản ở dạng đoạn văn (paragraph) đơn giản để đảm bảo hiển thị đồng nhất. Không gạch đầu dòng.''',
      );
    } else {
      buffer.writeln(
        "\nChưa có hướng dẫn bấm máy trong DB cho dạng này. Hãy giải tay từng bước và giải thích kỹ.",
      );
      buffer.writeln(
        '''QUY ĐỊNH TRÌNH BÀY:
    - KHÔNG sử dụng định dạng danh sách Markdown (1. 2. 3. hoặc * + -).
    - Thay vào đó, hãy viết các bước theo kiểu: Bước 1:, Bước 2:... hoặc gạch đầu dòng bằng ký tự '-' thủ công.
    - Giữ văn bản ở dạng đoạn văn (paragraph) đơn giản để đảm bảo hiển thị đồng nhất. Không gạch đầu dòng''',
      );
    }

    final response = await _chatModel.generateContent([Content.text(buffer.toString())]);
    return response.text ?? "Xin lỗi, AI không thể tạo câu trả lời.";
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
}
