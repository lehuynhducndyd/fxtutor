import '../models/login.dart';

abstract class Api {
  Future<bool> login(Login login);
  Future<void> logout();
  Future<bool> register(Login login);
}
