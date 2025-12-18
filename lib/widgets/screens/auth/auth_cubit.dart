import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/common/enum/load_status.dart';

import '../../../services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthState.init());

  Future<void> login(String email, String password) async {
    try {
      emit(state.copyWith(loadStatus: LoadStatus.Loading));
      await authService.signInWithEmailPassword(email, password);
      emit(state.copyWith(loadStatus: LoadStatus.Done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  Future<void> register(String email, String password, String confirmPassword) async {
    try {
      if (password != confirmPassword) {
        emit(state.copyWith(loadStatus: LoadStatus.Error));
        return;
      }
      emit(state.copyWith(loadStatus: LoadStatus.Loading));
      await authService.signUpWithEmailPassword(email, password);
      emit(state.copyWith(loadStatus: LoadStatus.Done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  Future<void> logout() async {
    await authService.signOut();
  }
}
