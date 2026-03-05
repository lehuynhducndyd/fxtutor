import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/contribute_model.dart';
import '../../../services/contribute_service.dart';
import '../../../services/email_service.dart';

// --- STATE ---
enum ContributeLoadStatus { initial, loading, success, error }

class ContributeState {
  final ContributeLoadStatus loadStatus;
  final List<ContributeModel> contributions;
  final String? errorMessage;

  ContributeState({
    this.loadStatus = ContributeLoadStatus.initial,
    this.contributions = const [],
    this.errorMessage,
  });

  ContributeState copyWith({
    ContributeLoadStatus? loadStatus,
    List<ContributeModel>? contributions,
    String? errorMessage,
  }) {
    return ContributeState(
      loadStatus: loadStatus ?? this.loadStatus,
      contributions: contributions ?? this.contributions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// --- CUBIT ---
class ContributeCubit extends Cubit<ContributeState> {
  final ContributeService _service;

  final EmailService _emailService = EmailService();

  ContributeCubit(this._service) : super(ContributeState());

  Future<void> loadContributions() async {
    emit(state.copyWith(loadStatus: ContributeLoadStatus.loading));
    try {
      final list = await _service.getMyContributions();
      emit(
        state.copyWith(
          loadStatus: ContributeLoadStatus.success,
          contributions: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: ContributeLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> submitContribution(String content) async {
    try {
      // 1. Lưu đóng góp vào Database trước
      await _service.addContribution(content);

      // 2. Lấy thông tin User hiện tại
      final currentUser = Supabase.instance.client.auth.currentUser;
      final userEmail = currentUser?.email ?? 'Người dùng ẩn danh';

      // 3. ĐỢI Bắn email thẳng cho Admin rồi mới báo thành công (Thêm chữ await)
      await _notifyAdminViaEmail(userEmail, content);

      // 4. Load lại list
      await loadContributions();
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: ContributeLoadStatus.error,
          errorMessage: "Lỗi khi gửi đóng góp: $e",
        ),
      );
      return false;
    }
  }

  // Hàm hỗ trợ soạn và gửi email cho Admin
  Future<void> _notifyAdminViaEmail(String userEmail, String content) async {
    // Đã xóa bỏ các dấu backslash (\) thừa để biến lấy đúng giá trị
    final htmlBody =
        '''
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eaeaea; border-radius: 12px;">
        <h2 style="color: #d9534f; border-bottom: 2px solid #d9534f; padding-bottom: 8px;">Có đóng góp mới!</h2>
        <p>Hệ thống FX Tutor vừa nhận được một ý kiến đóng góp mới.</p>
        
        <p><strong>Người gửi:</strong> <span style="color: #0d6efd;">$userEmail</span></p>
        
        <div style="background-color: #f8f9fa; padding: 16px; border-left: 4px solid #ffc107; margin-top: 16px; border-radius: 4px;">
          <strong style="color: #495057;">Nội dung:</strong><br><br>
          <span style="color: #212529; white-space: pre-wrap;">"$content"</span>
        </div>
        
        <p style="margin-top: 32px; font-size: 14px;">Vui lòng truy cập trang Quản trị Admin để kiểm duyệt và phản hồi người dùng.</p>
      </div>
    ''';

    await _emailService.sendEmail(
      toEmail: 'lehuynhducndyd@gmail.com', // Bắn về email QTV
      subject:
          'FX Tutor - Đóng góp mới từ $userEmail', // Đã xóa icon 🚨 ở Subject để tránh bộ lọc Spam
      htmlContent: htmlBody,
    );
  }
}
