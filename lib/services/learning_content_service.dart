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
}
