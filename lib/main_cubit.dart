import 'package:bloc/bloc.dart';
import 'package:fx_tutor/repositories/settings_store.dart';

import 'common/enum/drawer_item.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  SettingsStore settingsStore;
  MainCubit(this.settingsStore) : super(MainState.init()) {
    settingsStore.getIsLightTheme().then((value) {
      emit(state.copyWith(isLightTheme: value));
    });
  }

  void loadTheme() {
    settingsStore.getIsLightTheme().then((value) async {
      emit(state.copyWith(isLightTheme: value));
    });
  }

  void setSelected(DrawerItem selected) {
    emit(state.copyWith(selected: selected));
  }

  void setTheme(bool isLightTheme) {
    settingsStore.setIsLightTheme(isLightTheme);
    emit(state.copyWith(isLightTheme: isLightTheme));
  }
}
