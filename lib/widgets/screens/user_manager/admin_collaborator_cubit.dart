import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/collaborator_require_model.dart';
import '../../../services/collaborator_service.dart';
import '../../../services/email_service.dart';

class AdminCollaboratorState {
  final bool isLoading;
  final List<CollaboratorRequireModel> requests;
  final String? error;

  AdminCollaboratorState({this.isLoading = false, this.requests = const [], this.error});
}

class AdminCollaboratorCubit extends Cubit<AdminCollaboratorState> {
  final CollaboratorService _service;

  final EmailService _emailService = EmailService();

  AdminCollaboratorCubit(this._service) : super(AdminCollaboratorState());

  Future<void> loadRequests() async {
    emit(AdminCollaboratorState(isLoading: true));
    try {
      final list = await _service.getPendingRequests();
      emit(AdminCollaboratorState(requests: list));
    } catch (e) {
      emit(AdminCollaboratorState(error: e.toString()));
    }
  }

  Future<bool> handleRequest(String requestId, String targetUserId, bool isApproved) async {
    try {
      // 1. Tìm thông tin yêu cầu để lấy Email của user trước khi gọi API làm mất data
      final targetRequest = state.requests.firstWhere((req) => req.id == requestId);

      // 2. Cập nhật trạng thái vào Database
      final status = isApproved ? 'approved' : 'rejected';
      await _service.processRequest(requestId, targetUserId, status);

      // 3. Gửi email thông báo kết quả cho User (Chờ gửi xong)
      await _notifyUserViaEmail("lehuynhducndyd@gmail.com", isApproved);

      // 4. Load lại danh sách cho mất dòng đã duyệt đi
      await loadRequests();
      return true;
    } catch (e) {
      emit(AdminCollaboratorState(requests: state.requests, error: e.toString()));
      return false;
    }
  }

  // ================= HÀM HỖ TRỢ GỬI EMAIL (KHÔNG DÙNG ICON) =================
  Future<void> _notifyUserViaEmail(String toEmail, bool isApproved) async {
    final subject = isApproved
        ? 'FX Tutor - Chúc mừng! Yêu cầu Cộng tác viên đã được duyệt'
        : 'FX Tutor - Kết quả đăng ký Cộng tác viên';

    final statusHtml = isApproved
        ? '<span style="color: #28a745; font-weight: bold;">ĐÃ ĐƯỢC PHÊ DUYỆT</span>'
        : '<span style="color: #dc3545; font-weight: bold;">TỪ CHỐI</span>';

    final messageHtml = isApproved
        ? 'Chúc mừng bạn đã chính thức trở thành <strong>Cộng tác viên</strong> của FX Tutor! Giờ đây, bạn có quyền truy cập vào các công cụ quản trị để thêm mới, chỉnh sửa Bài học và Hướng dẫn bấm máy trên hệ thống. Cảm ơn bạn đã đồng hành cùng chúng tôi phát triển cộng đồng học tập.'
        : 'Rất tiếc, yêu cầu trở thành Cộng tác viên của bạn chưa phù hợp với định hướng của hệ thống ở thời điểm hiện tại. Tuy nhiên, bạn vẫn có thể tiếp tục đóng góp ý kiến thông qua tính năng "Đóng góp" trên ứng dụng. Cảm ơn bạn đã quan tâm!';

    final borderColor = isApproved ? '#28a745' : '#dc3545';

    final htmlBody =
        '''
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eaeaea; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <h2 style="color: #0d6efd; text-align: center;">Xin chào!</h2>
        <p>Hệ thống <strong>FX Tutor</strong> xin thông báo về kết quả đăng ký làm Cộng tác viên của tài khoản <strong>$toEmail</strong>.</p>
        
        <p>Trạng thái yêu cầu: $statusHtml</p>
        
        <div style="background-color: #f8f9fa; padding: 16px; border-left: 4px solid $borderColor; margin-top: 20px; border-radius: 0 8px 8px 0;">
          <span style="color: #212529;">$messageHtml</span>
        </div>
        
        <p style="margin-top: 32px; font-size: 14px;">Nếu có bất kỳ thắc mắc nào, bạn có thể liên hệ lại với Ban quản trị.</p>
        <hr style="border: none; border-top: 1px solid #eaeaea; margin: 24px 0;">
        <p style="font-size: 12px; color: #adb5bd; text-align: center;">Đây là email tự động từ hệ thống FX Tutor, vui lòng không trả lời thư này.</p>
      </div>
    ''';

    try {
      await _emailService.sendEmail(
        toEmail: toEmail,
        subject: subject,
        htmlContent: htmlBody,
      );
      print('>>> Đã gửi email thông báo duyệt CTV cho $toEmail');
    } catch (e) {
      print('>>> Lỗi gửi email duyệt CTV: $e');
    }
  }
}
