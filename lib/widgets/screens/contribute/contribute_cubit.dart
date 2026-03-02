import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/contribute_model.dart';
import '../../../services/contribute_service.dart';

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

  ContributeCubit(this._service) : super(ContributeState());

  // Tải danh sách đóng góp
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

  // Gửi đóng góp mới
  Future<bool> submitContribution(String content) async {
    // emit loading cho riêng việc submit nếu cần, nhưng ở đây ta dùng Dialog ở UI
    try {
      await _service.addContribution(content);
      await loadContributions(); // Load lại list sau khi thêm thành công
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
}
