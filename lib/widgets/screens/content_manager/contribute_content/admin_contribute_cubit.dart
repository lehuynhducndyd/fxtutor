import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/admin_contribute_model.dart';
import '../../../../services/admin_contribute_service.dart';
import '../../../../services/email_service.dart'; // Import service

enum AdminContributeStatus { initial, loading, success, error }

class AdminContributeState {
  final AdminContributeStatus loadStatus;
  final List<AdminContributeModel> contributions;
  final String? errorMessage;

  AdminContributeState({
    this.loadStatus = AdminContributeStatus.initial,
    this.contributions = const [],
    this.errorMessage,
  });

  AdminContributeState copyWith({
    AdminContributeStatus? loadStatus,
    List<AdminContributeModel>? contributions,
    String? errorMessage,
  }) {
    return AdminContributeState(
      loadStatus: loadStatus ?? this.loadStatus,
      contributions: contributions ?? this.contributions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AdminContributeCubit extends Cubit<AdminContributeState> {
  final AdminContributeService _service;

  // KHỞI TẠO TRỰC TIẾP, KHÔNG CẦN TIÊM DI
  final EmailService _emailService = EmailService();

  AdminContributeCubit(this._service) : super(AdminContributeState());

  Future<void> loadAllContributions() async {
    emit(state.copyWith(loadStatus: AdminContributeStatus.loading));
    try {
      final list = await _service.getAllContributions();
      emit(
        state.copyWith(
          loadStatus: AdminContributeStatus.success,
          contributions: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: AdminContributeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> review(String id, String status, String responseText) async {
    try {
      final targetContribute = state.contributions.firstWhere((c) => c.id == id);

      // Cập nhật Database
      await _service.reviewContribution(
        contributeId: id,
        status: status,
        responseText: responseText,
      );

      // Gọi hàm gửi email ngầm bên dưới
      _sendEmailNotification(
        toEmail: targetContribute.userEmail,
        status: status,
        originalContent: targetContribute.content,
        adminResponse: responseText,
      );

      // Tải lại danh sách
      await loadAllContributions();
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: AdminContributeStatus.error,
          errorMessage: "Lỗi khi duyệt: $e",
        ),
      );
      return false;
    }
  }

  // Khâu chuẩn bị giao diện HTML và Gửi qua EmailService
  Future<void> _sendEmailNotification({
    required String toEmail,
    required String status,
    required String originalContent,
    required String adminResponse,
  }) async {
    final isApproved = status == 'approved';
    final subject = isApproved
        ? 'FX Tutor - Đóng góp của bạn đã được duyệt!'
        : 'FX Tutor - Phản hồi về đóng góp của bạn';

    final statusHtml = isApproved
        ? '<span style="color: #28a745; font-weight: bold;">ĐÃ ĐƯỢC DUYỆT</span>'
        : '<span style="color: #dc3545; font-weight: bold;">TỪ CHỐI</span>';

    final htmlBody =
        '''
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eaeaea; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <h2 style="color: #0d6efd; text-align: center;">Xin chào!</h2>
        <p>Cảm ơn bạn đã dành thời gian gửi ý kiến đóng góp cho ứng dụng <strong>FX Tutor</strong>.</p>
        <p>Chúng tôi xin thông báo đóng góp của bạn hiện tại: $statusHtml</p>
        
        <div style="background-color: #f8f9fa; padding: 16px; border-left: 4px solid #0d6efd; margin-top: 20px; border-radius: 0 8px 8px 0;">
          <strong style="color: #495057;">Nội dung bạn đã gửi:</strong><br>
          <i style="color: #6c757d;">"$originalContent"</i>
        </div>
        
        <div style="background-color: #e8f4fd; padding: 16px; border-left: 4px solid #0dcaf0; margin-top: 16px; border-radius: 0 8px 8px 0;">
          <strong style="color: #495057;">Phản hồi từ Ban quản trị:</strong><br>
          <span style="color: #212529;">$adminResponse</span>
        </div>
        
        <p style="margin-top: 32px; font-size: 14px;">Nếu bạn có bất kỳ thắc mắc nào, vui lòng phản hồi lại email lehuynhducndyd@gmail.com.</p>
        <hr style="border: none; border-top: 1px solid #eaeaea; margin: 24px 0;">
        <p style="font-size: 12px; color: #adb5bd; text-align: center;">Đây là email tự động từ hệ thống FX Tutor, vui lòng không trả lời thư này.</p>
      </div>
    ''';

    // Sử dụng _emailService đã khởi tạo sẵn
    await _emailService.sendEmail(
      toEmail: toEmail,
      subject: subject,
      htmlContent: htmlBody,
    );
  }
}
