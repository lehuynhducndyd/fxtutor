import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/calculator_guide_model.dart';

class GuideManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GenerativeModel _embeddingModel;

  GuideManagementService()
    : _embeddingModel = GenerativeModel(
        model: 'text-embedding-004',
        apiKey: dotenv.env['API_KEY'] ?? '',
      );

  Future<List<CalculatorGuideModel>> fetchAllGuides(int topicId) async {
    final response = await _supabase
        .from('calculator_guides')
        .select()
        .eq('topic_id', topicId) // <--- QUAN TRỌNG: Thêm dòng này để lọc theo Topic
        .order('created_at', ascending: false);
    return (response as List).map((e) => CalculatorGuideModel.fromJson(e)).toList();
  }

  Future<void> createGuide(CalculatorGuideModel guide) async {
    final vector = await _generateEmbedding(guide.actionName);
    final data = guide.toJson();
    data['embedding'] = vector;
    await _supabase.from('calculator_guides').insert(data);
  }

  Future<void> updateGuide(CalculatorGuideModel guide) async {
    final vector = await _generateEmbedding(guide.actionName);
    final data = guide.toJson();
    data['embedding'] = vector;
    await _supabase.from('calculator_guides').update(data).eq('id', guide.id!);
  }

  Future<void> deleteGuide(int id) async {
    await _supabase.from('calculator_guides').delete().eq('id', id);
  }

  Future<List<double>> _generateEmbedding(String text) async {
    final result = await _embeddingModel.embedContent(Content.text(text));
    return result.embedding.values;
  }
}
