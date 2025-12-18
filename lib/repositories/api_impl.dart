import 'package:fx_tutor/models/login.dart';
import 'package:fx_tutor/repositories/api.dart';

import 'log.dart';

class ApiImpl implements Api {
  Log log;
  ApiImpl(this.log);
  @override
  Future<bool> login(Login login) {
    // TODO: implement auth
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<bool> register(Login login) {
    // TODO: implement register
    throw UnimplementedError();
  }
}
