import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/topic_model.dart';

class TopicService {
  // Lấy client từ instance
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'topics';

  /// 1. LẤY DANH SÁCH (READ)
  /// Lấy tất cả topic, sắp xếp theo ngày tạo mới nhất
  Future<List<TopicModel>> getTopics() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: true); // Sắp xếp tăng dần

      // Parse dữ liệu: List<dynamic> -> List<TopicModel>
      final List<dynamic> data = response;
      return data.map((json) => TopicModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách chủ đề: $e');
    }
  }

  /// 2. THÊM MỚI (CREATE)
  /// Trả về TopicModel vừa tạo để UI update ngay lập tức
  Future<TopicModel> addTopic(String title, String description) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from(_table)
          .insert({
            'title': title,
            'description': description,
            'user_id': userId,
          })
          .select() // Quan trọng: select() để Supabase trả về dòng vừa insert
          .single(); // Lấy 1 object

      return TopicModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi thêm chủ đề: $e');
    }
  }

  /// 3. CẬP NHẬT (UPDATE)
  Future<void> updateTopic(int id, String title, String description) async {
    try {
      await _client
          .from(_table)
          .update({
            'title': title,
            'description': description,
          })
          .eq('id', id); // Điều kiện: Update dòng có id này
    } catch (e) {
      throw Exception('Lỗi cập nhật chủ đề: $e');
    }
  }

  /// 4. XÓA (DELETE)
  Future<void> deleteTopic(int id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Lỗi xóa chủ đề: $e');
    }
  }
}
