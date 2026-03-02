import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/collaborator_require_model.dart';
import '../../../services/collaborator_service.dart';

class AdminCollaboratorState {
  final bool isLoading;
  final List<CollaboratorRequireModel> requests;
  final String? error;

  AdminCollaboratorState({this.isLoading = false, this.requests = const [], this.error});
}

class AdminCollaboratorCubit extends Cubit<AdminCollaboratorState> {
  final CollaboratorService _service;

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
      final status = isApproved ? 'approved' : 'rejected';
      await _service.processRequest(requestId, targetUserId, status);
      await loadRequests(); // Load lại danh sách cho mất dòng đã duyệt đi
      return true;
    } catch (e) {
      emit(AdminCollaboratorState(requests: state.requests, error: e.toString()));
      return false;
    }
  }
}
