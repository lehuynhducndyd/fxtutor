import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/collaborator_require_model.dart';

class CollaboratorService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ================= PHÍA USER =================
  // 1. User gửi yêu cầu
  Future<void> requestToCollaborate() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Chưa đăng nhập');

    // Kiểm tra xem đã gửi yêu cầu nào đang pending chưa để tránh spam
    final existing = await _supabase
        .from('collaborator_require')
        .select()
        .eq('user_id', userId)
        .eq('status', 'pending');

    if (existing.isNotEmpty) {
      throw Exception('Bạn đã gửi yêu cầu rồi, vui lòng chờ Admin duyệt!');
    }

    await _supabase.from('collaborator_require').insert({'user_id': userId});
  }

  // ================= PHÍA ADMIN =================
  // 2. Admin lấy danh sách chờ duyệt
  Future<List<CollaboratorRequireModel>> getPendingRequests() async {
    final response = await _supabase
        .from('collaborator_require')
        .select('*, users(email)')
        .eq('status', 'pending') // Chỉ lấy những người đang chờ duyệt
        .order('created_at', ascending: true);

    return (response as List).map((e) => CollaboratorRequireModel.fromJson(e)).toList();
  }

  // 3. Admin xử lý yêu cầu (Duyệt/Từ chối)
  Future<void> processRequest(String requestId, String targetUserId, String newStatus) async {
    // Bước 1: Cập nhật trạng thái trong bảng collaborator_require
    await _supabase.from('collaborator_require').update({'status': newStatus}).eq('id', requestId);

    // Bước 2: NẾU DUYỆT (approved) -> Nâng cấp role của user đó thành collaborator
    if (newStatus == 'approved') {
      await _supabase.from('users').update({'role': 'collaborator'}).eq('id', targetUserId);
    }
  }

  // Hàm lấy thông tin yêu cầu hiện tại của User (lấy cái mới nhất)
  Future<CollaboratorRequireModel?> getMyRequestStatus() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    final response = await _supabase
        .from('collaborator_require')
        .select('*, users(email)') // Lấy thêm email để parser model không bị lỗi
        .eq('user_id', userId)
        .order('created_at', ascending: false) // Sắp xếp giảm dần (mới nhất lên đầu)
        .limit(1); // Chỉ lấy 1 bản ghi duy nhất

    final data = response as List;

    if (data.isEmpty) {
      return null; // Trả về null nếu user chưa từng gửi yêu cầu nào
    }

    // Parse dòng đầu tiên lấy được thành Model
    return CollaboratorRequireModel.fromJson(data.first);
  }
}
