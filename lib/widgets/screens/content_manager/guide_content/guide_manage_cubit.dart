import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/calculator_guide_model.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/guide_management_service.dart';

part 'guide_manage_state.dart';

class GuideManageCubit extends Cubit<GuideManageState> {
  final GuideManagementService _service;

  GuideManageCubit(this._service) : super(GuideManageState(status: LoadStatus.Init, guides: []));
  Future<void> loadGuides(int topicId) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      final data = await _service.fetchAllGuides(topicId);
      emit(
        state.copyWith(
          status: LoadStatus.Done,
          guides: data,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: "Lỗi tải danh sách: $e"));
    }
  }

  Future<void> addGuide(CalculatorGuideModel guide, int topicId) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      await _service.createGuide(guide);
      final newData = await _service.fetchAllGuides(topicId);

      emit(
        state.copyWith(
          status: LoadStatus.Done,
          guides: newData,
          successMessage: "Thêm hướng dẫn thành công!",
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: "Lỗi thêm mới: $e"));
    }
  }

  // 3. Sửa hướng dẫn
  Future<void> editGuide(CalculatorGuideModel guide, int topicId) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      await _service.updateGuide(guide);

      final newData = await _service.fetchAllGuides(topicId);

      emit(
        state.copyWith(
          status: LoadStatus.Done,
          guides: newData,
          successMessage: "Cập nhật thành công!",
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: "Lỗi cập nhật: $e"));
    }
  }

  // 4. Xóa hướng dẫn
  Future<void> deleteGuide(int id) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      await _service.deleteGuide(id);

      // Xóa item khỏi list hiện tại luôn để đỡ phải gọi API load lại (Optimistic UI)
      // Hoặc gọi fetchAllGuides() nếu muốn chắc chắn đồng bộ server
      final updatedList = List<CalculatorGuideModel>.from(state.guides)
        ..removeWhere((g) => g.id == id);

      emit(
        state.copyWith(
          status: LoadStatus.Done,
          guides: updatedList,
          successMessage: "Đã xóa hướng dẫn!",
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: "Lỗi xóa: $e"));
    }
  }
}
