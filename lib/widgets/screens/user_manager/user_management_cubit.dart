import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/user_model.dart';
import '../../../services/user_management_service.dart';

enum UserListStatus { initial, loading, success, error }

class UserManagementState {
  final UserListStatus status;
  final List<UserModel> users;
  final String? errorMessage;

  UserManagementState({
    this.status = UserListStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  UserManagementState copyWith({
    UserListStatus? status,
    List<UserModel>? users,
    String? errorMessage,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserManagementService _service;

  UserManagementCubit(this._service) : super(UserManagementState());

  // Tải danh sách, truyền thêm chữ để tìm kiếm
  Future<void> loadUsers({String query = ''}) async {
    emit(state.copyWith(status: UserListStatus.loading));
    try {
      final list = await _service.getUsers(query: query);
      emit(state.copyWith(status: UserListStatus.success, users: list));
    } catch (e) {
      emit(state.copyWith(status: UserListStatus.error, errorMessage: e.toString()));
    }
  }

  // Thay đổi quyền
  Future<bool> changeRole(String userId, String newRole) async {
    try {
      await _service.updateUserRole(userId, newRole);

      // Cập nhật lại UI ngay lập tức bằng cách sửa list local (đỡ phải gọi API load lại toàn bộ)
      final updatedList = state.users.map((u) {
        if (u.id == userId) {
          return UserModel(
            id: u.id,
            email: u.email,
            fullName: u.fullName,
            role: newRole,
            isActive: u.isActive,
            createdAt: u.createdAt,
          );
        }
        return u;
      }).toList();

      emit(state.copyWith(users: updatedList));
      return true;
    } catch (e) {
      emit(state.copyWith(status: UserListStatus.error, errorMessage: "Lỗi cập nhật: $e"));
      return false;
    }
  }

  Future<bool> toggleActiveStatus(String userId, bool currentStatus) async {
    try {
      await _service.toggleUserActiveStatus(userId, currentStatus);

      // Cập nhật local state y như lúc đổi quyền
      final updatedList = state.users.map((u) {
        if (u.id == userId) {
          return UserModel(
            id: u.id,
            email: u.email,
            fullName: u.fullName,
            role: u.role,
            isActive: !currentStatus,
            createdAt: u.createdAt,
          );
        }
        return u;
      }).toList();

      emit(state.copyWith(users: updatedList));
      return true;
    } catch (e) {
      emit(state.copyWith(status: UserListStatus.error, errorMessage: "Lỗi cập nhật: $e"));
      return false;
    }
  }
}
