import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/load_status.dart';
import 'package:fx_tutor/models/user_model.dart';
import 'package:fx_tutor/services/profile_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;

  ProfileCubit(this.profileService) : super(ProfileState.initial());

  Future<void> loadUser() async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));

    UserModel? user;

    // Thử lấy dữ liệu tối đa 3 lần
    for (int i = 0; i < 3; i++) {
      try {
        user = await profileService.getCurrentProfile();

        // Nếu lấy được user rồi thì thoát vòng lặp ngay
        if (user != null) {
          break;
        }
      } catch (e) {
        print("Lần thử $i bị lỗi: $e");
      }

      // Nếu chưa lấy được, đợi 1 giây rồi thử lại (để chờ Trigger chạy xong)
      if (i < 2) {
        // Chỉ đợi ở lần 0 và 1
        print("⏳ Đang đợi Trigger tạo dữ liệu... (Lần ${i + 1})");
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // Kiểm tra kết quả cuối cùng
    if (user == null) {
      print("❌ Đã thử 3 lần nhưng vẫn không thấy user.");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
      return;
    }

    print("✅ Đã load được user: ${user.email}");
    emit(state.copyWith(user: user, loadStatus: LoadStatus.Done));
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    try {
      emit(state.copyWith(loadStatus: LoadStatus.Loading));
      await profileService.updateProfile(fullName: fullName, avatarUrl: avatarUrl);
      await loadUser();
      emit(state.copyWith(loadStatus: LoadStatus.Done));
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: LoadStatus.Error,
        ),
      );
    }
  }

  // Thêm vào Cubit quản lý màn hình hiện tại (ví dụ: ProfileCubit)

  Future<void> changePassword(String newPassword) async {
    try {
      emit(state.copyWith(loadStatus: LoadStatus.Loading)); // Hiện loading

      await profileService.changePassword(newPassword);

      emit(
        state.copyWith(
          loadStatus: LoadStatus.Done,
        ),
      );
    } catch (e) {
      print("Lỗi đổi mật khẩu: $e");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }
}
