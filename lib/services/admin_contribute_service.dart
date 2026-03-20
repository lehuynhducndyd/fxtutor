import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_contribute_model.dart';

class AdminContributeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy tất cả đóng góp (Dùng Left Join: users(email) thay vì !inner)
  Future<List<AdminContributeModel>> getAllContributions() async {
    final response = await _supabase
        .from('contribute')
        .select('*, users(email)')
        .order('created_at', ascending: false);

    return (response as List).map((e) => AdminContributeModel.fromJson(e)).toList();
  }

  // Hàm duyệt hoặc từ chối kèm phản hồi
  Future<void> reviewContribution({
    required String contributeId,
    required String status,
    required String responseText,
  }) async {
    await _supabase
        .from('contribute')
        .update({
          'status': status,
          'response': responseText,
        })
        .eq('id', contributeId);
  }

  // Xóa đóng góp
  Future<void> deleteContribution(String id) async {
    await _supabase.from('contribute').delete().eq('id', id);
  }
}
