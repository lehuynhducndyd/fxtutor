import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/learning_content.dart';
import '../models/user_model.dart';

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
    final userId = _supabase.auth.currentUser?.id;
    // Convert List Object -> List Map (JSON)
    final blocksJson = blocks.map((e) => e.toJson()).toList();

    await _supabase.from('learning_content').insert({
      'user_id': userId, // Sử dụng ID của người dùng hiện tại'
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

  Future<UserModel> getUserById(String userId) async {
    try {
      // 1. Truy vấn bảng 'users', lọc theo cột 'id'
      final data = await _supabase
          .from('users')
          .select() // Lấy tất cả các cột
          .eq('id', userId) // Điều kiện: id bằng userId truyền vào
          .single(); // .single() trả về 1 Object (Map) thay vì 1 List.
      // Nếu không tìm thấy hoặc tìm thấy > 1 dòng, nó sẽ báo lỗi.

      // 2. Convert Map sang UserModel
      return UserModel.fromJson(data);
    } catch (e) {
      // 3. Xử lý lỗi (ví dụ: in ra log hoặc ném tiếp ra ngoài)
      print('Lỗi lấy thông tin user: $e');
      throw Exception('Không tìm thấy người dùng hoặc lỗi mạng');
    }
  }
}
