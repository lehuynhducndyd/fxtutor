import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/admin_contribute_model.dart';
import '../../../../services/admin_contribute_service.dart';

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
      await _service.reviewContribution(
        contributeId: id,
        status: status,
        responseText: responseText,
      );
      // Cập nhật thành công thì tải lại danh sách
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
}
