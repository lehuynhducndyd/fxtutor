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
    UserModel? user = await profileService.getCurrentProfile();
    print(user);
    if (user == null) {
      emit(state.copyWith(loadStatus: LoadStatus.Error));
      return;
    }
    emit(state.copyWith(user: user, loadStatus: LoadStatus.Done));
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    await profileService.updateProfile(fullName: fullName, avatarUrl: avatarUrl);
    await loadUser();
    emit(state.copyWith(loadStatus: LoadStatus.Done));
  }
}
