import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Gọi Supabase Edge Function để gửi email
  Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      // Gọi đúng tên thư mục function mà bạn đã deploy trên Supabase
      final response = await _supabase.functions.invoke(
        'smooth-api',
        body: {
          'to': toEmail,
          'subject': subject,
          'html': htmlContent,
        },
      );

      // Log để debug (tùy chọn)
      print('Gửi email thành công: ${response.data}');
      return true;
    } on FunctionException catch (e) {
      // Bắt lỗi riêng của Supabase Function (VD: Lỗi code TS, lỗi timeout)
      print('Lỗi Supabase Function: ${e.reasonPhrase} - Chi tiết: ${e.details}');
      return false;
    } catch (e) {
      // Bắt các lỗi khác (VD: Mất mạng)
      print('Lỗi không xác định khi gửi email: $e');
      return false;
    }
  }
}
