import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class UserManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy danh sách user (Có hỗ trợ tìm kiếm theo email hoặc tên)
  Future<List<UserModel>> getUsers({String query = ''}) async {
    var request = _supabase.from('users').select();

    // Nếu có nhập từ khóa tìm kiếm (dùng ilike để tìm kiếm không phân biệt hoa thường)
    if (query.trim().isNotEmpty) {
      request = request.or('email.ilike.%${query.trim()}%,full_name.ilike.%${query.trim()}%');
    }

    final response = await request.order('created_at', ascending: false);
    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  // Cập nhật quyền (role) cho user
  Future<void> updateUserRole(String userId, String newRole) async {
    await _supabase.from('users').update({'role': newRole}).eq('id', userId);
  }

  Future<void> toggleUserActiveStatus(String userId, bool currentStatus) async {
    // Nếu đang active (true) thì up lên false (khóa), và ngược lại
    await _supabase.from('users').update({'is_active': !currentStatus}).eq('id', userId);
  }
}
