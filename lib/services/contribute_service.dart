import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contribute_model.dart';

class ContributeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy danh sách đóng góp của User hiện tại
  Future<List<ContributeModel>> getMyContributions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');
    final response = await _supabase
        .from('contribute')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false); // Mới nhất xếp trên

    return (response as List).map((e) => ContributeModel.fromJson(e)).toList();
  }

  // Thêm đóng góp mới
  Future<void> addContribution(String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    await _supabase.from('contribute').insert({
      'user_id': userId,
      'content': content,
      // status tự nhận default là 'pending' từ database
    });
  }
}
