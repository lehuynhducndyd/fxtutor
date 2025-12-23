part of 'profile_cubit.dart';

class ProfileState {
  final UserModel user;
  final LoadStatus loadStatus;

  factory ProfileState.initial() {
    return ProfileState(
      user: UserModel(
        id: '',
        createdAt: DateTime.now(), // Hợp lệ khi dùng trong body của factory
      ),
      loadStatus: LoadStatus.Init,
    );
  }

  //<editor-fold desc="Data Methods">
  const ProfileState({
    required this.user,
    required this.loadStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileState &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          loadStatus == other.loadStatus);

  @override
  int get hashCode => user.hashCode ^ loadStatus.hashCode;

  @override
  String toString() {
    return 'ProfileState{' + ' user: $user,' + ' loadStatus: $loadStatus,' + '}';
  }

  ProfileState copyWith({
    UserModel? user,
    LoadStatus? loadStatus,
  }) {
    return ProfileState(
      user: user ?? this.user,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': this.user,
      'loadStatus': this.loadStatus,
    };
  }

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      user: map['user'] as UserModel,
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }

  //</editor-fold>
}
