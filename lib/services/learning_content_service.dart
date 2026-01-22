import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/learning_content.dart';

class LearningService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy danh sách bài học thuộc về một chủ đề (Topic)
  Future<List<LearningContent>> fetchContentsByTopic(int topicId) async {
    try {
      final response = await _supabase
          .from('learning_content')
          .select()
          .eq('topic_id', topicId)
          .order('created_at', ascending: true); // Sắp xếp bài cũ lên trước

      final dataList = response as List<dynamic>;

      return dataList.map((e) => LearningContent.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Lỗi tải bài học: $e");
    }
  }

  Future<void> createContent({
    required int topicId,
    required String title,
    required List<ContentBlock> blocks,
  }) async {
    // Convert List Object -> List Map (JSON)
    final blocksJson = blocks.map((e) => e.toJson()).toList();

    await _supabase.from('learning_content').insert({
      'topic_id': topicId,
      'title': title,
      'content': blocksJson, // Supabase tự hiểu đây là jsonb
    });
  }

  // 2. CẬP NHẬT (Update)
  Future<void> updateContent({
    required int id,
    required String title,
    required List<ContentBlock> blocks,
  }) async {
    final blocksJson = blocks.map((e) => e.toJson()).toList();

    await _supabase
        .from('learning_content')
        .update({
          'title': title,
          'content': blocksJson,
        })
        .eq('id', id);
  }

  // 3. XÓA (Delete)
  Future<void> deleteContent(int id) async {
    await _supabase.from('learning_content').delete().eq('id', id);
  }
}
