import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  Future<void> setIsLightTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightTheme', value);
  }

  Future<bool> getIsLightTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLightTheme') ?? true;
  }
}
