import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/calculator_guide_model.dart';

class AiChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GenerativeModel _chatModel;
  final GenerativeModel _embeddingModel;

  AiChatService()
    : _chatModel = GenerativeModel(model: 'gemini-2.5-flash', apiKey: dotenv.env['API_KEY'] ?? ''),
      _embeddingModel = GenerativeModel(
        model: 'text-embedding-004',
        apiKey: dotenv.env['API_KEY'] ?? '',
      );

  Future<String> solveAndGuide({
    String? textInput,
    Uint8List? imageBytes,
    required String userModel,
  }) async {
    try {
      // BƯỚC 1: Xác định Topic từ Input
      final analysis = await _identifyTopic(textInput, imageBytes);
      final topicName = analysis['topic']!;
      final specificProblem = analysis['problem']!;

      // BƯỚC 2: Vector Search tìm hướng dẫn
      final guide = await _searchSupabaseForGuide(topicName);

      // BƯỚC 3: Tạo câu trả lời cuối cùng
      return await _generateFinalResponse(
        userProblem: specificProblem,
        topicFound: topicName,
        guide: guide,
        userModel: userModel,
      );
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  Future<Map<String, String>> _identifyTopic(String? text, Uint8List? image) async {
    final promptText =
        "Phân tích và trả về JSON: {'topic': 'Tên dạng toán chung', 'problem': 'Đề bài cụ thể'}";
    final content = [
      if (image != null) Content.multi([TextPart(promptText), DataPart('image/jpeg', image)]),
      if (text != null) Content.text("$promptText\nUser Input: $text"),
    ];

    final response = await _chatModel.generateContent(content);
    String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
    if (cleanJson.startsWith('{') && cleanJson.endsWith('}')) {
      try {
        final data = jsonDecode(cleanJson);
        return {"topic": data['topic'], "problem": data['problem']};
      } catch (e) {
        return {"topic": response.text!, "problem": text ?? ""};
      }
    }
    return {"topic": cleanJson, "problem": text ?? ""};
  }

  Future<CalculatorGuideModel?> _searchSupabaseForGuide(String topicName) async {
    final embeddingRes = await _embeddingModel.embedContent(Content.text(topicName));
    final vector = embeddingRes.embedding.values;

    final List<dynamic> res = await _supabase.rpc(
      'match_guides',
      params: {'query_embedding': vector, 'match_threshold': 0.70, 'match_count': 1},
    );

    if (res.isNotEmpty) return CalculatorGuideModel.fromJson(res.first);
    return null;
  }

  Future<String> _generateFinalResponse({
    required String userProblem,
    required String topicFound,
    CalculatorGuideModel? guide,
    required String userModel,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(
      "Bạn là trợ lý toán học. User cần giải: '$userProblem' (Dạng: $topicFound). Máy tính: $userModel.",
    );

    if (guide != null) {
      buffer.writeln("\nHƯỚNG DẪN GỐC TỪ DB:");
      buffer.writeln("Máy hỗ trợ: ${guide.compatibleModels}");
      buffer.writeln("Cách bấm: ${guide.methods.map((e) => e.content).toList()}");
      buffer.writeln(
        "\nYÊU CẦU: Hướng dẫn giải bài toán trên dựa vào cách bấm mẫu. Các phím bấm phải để trong ngoặc vuông [ ]. Ví dụ: [MENU].",
      );
    } else {
      buffer.writeln("Chưa có hướng dẫn bấm máy. Hãy giải tay.");
    }

    final response = await _chatModel.generateContent([Content.text(buffer.toString())]);
    return response.text ?? "Lỗi AI";
  }
}
