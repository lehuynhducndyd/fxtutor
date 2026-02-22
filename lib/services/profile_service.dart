import 'package:supabase_flutter/supabase_flutter.dart';

// Nhớ import model bạn đã tạo ở bước trước
import '../models/user_model.dart';

class ProfileService {
  // Instance của Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 1. Lấy thông tin Profile của user đang đăng nhập hiện tại
  Future<UserModel?> getCurrentProfile() async {
    try {
      // Lấy ID của user đang đăng nhập (Auth ID)
      final userId = _supabase.auth.currentUser?.id;
      print("id: $userId");
      // Nếu chưa đăng nhập thì trả về null
      if (userId == null) return null;

      // Truy vấn bảng 'users'
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId) // Lọc theo ID
          .maybeSingle();

      // Convert dữ liệu JSON từ Supabase sang Object Dart (UserModel)
      if (data == null) {
        print("⚠️ User ID $userId chưa có trong bảng public.users");
        return null;
      }
      return UserModel.fromJson(data);
    } catch (e) {
      // In lỗi ra console để debug
      print('Lỗi lấy profile: $e');
      return null;
    }
  }

  Future<UserModel?> getProfileById(String userId) async {
    try {
      final data = await _supabase.from('users').select().eq('id', userId).single();
      return UserModel.fromJson(data);
    } catch (e) {
      print('Lỗi lấy profile theo ID: $e');
      return null;
    }
  }

  /// 2. Cập nhật thông tin (Tên hiển thị, Avatar)
  /// Sử dụng optional parameter {} để bạn có thể update 1 trong 2 hoặc cả 2
  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("Chưa đăng nhập");

      // Tạo map dữ liệu cần update
      final Map<String, dynamic> updates = {
        // Chỉ thêm vào map nếu giá trị không null
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      // Nếu không có gì để update thì return luôn cho đỡ tốn mạng
      if (updates.isEmpty) return;

      // Gọi lệnh update lên Supabase
      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId); // Chỉ update dòng của user hiện tại
    } catch (e) {
      print('Lỗi cập nhật profile: $e');
      rethrow; // Ném lỗi ra ngoài để UI hiển thị thông báo (SnackBar)
    }
  }

  bool isEmailProvider() {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    // Supabase lưu thông tin provider trong app_metadata
    final provider = user.appMetadata['provider'];
    return provider == 'email';
  }

  Future<void> changePassword(String newPassword) async {
    // Supabase chỉ cho phép đổi mật khẩu khi user đang đăng nhập hợp lệ
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
