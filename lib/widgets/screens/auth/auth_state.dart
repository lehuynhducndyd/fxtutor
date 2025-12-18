part of 'auth_cubit.dart';

class AuthState {
  final LoadStatus loadStatus;

  const AuthState.init({
    this.loadStatus = LoadStatus.Init,
  });

  //<editor-fold desc="Data Methods">
  const AuthState({
    required this.loadStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthState && runtimeType == other.runtimeType && loadStatus == other.loadStatus);

  @override
  int get hashCode => loadStatus.hashCode;

  @override
  String toString() {
    return 'AuthState{' + ' loadStatus: $loadStatus,' + '}';
  }

  AuthState copyWith({
    LoadStatus? loadStatus,
  }) {
    return AuthState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
    };
  }

  factory AuthState.fromMap(Map<String, dynamic> map) {
    return AuthState(
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }

  //</editor-fold>
}
