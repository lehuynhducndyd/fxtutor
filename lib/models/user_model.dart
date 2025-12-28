class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      role: json['role'],
    );
  }

  //<editor-fold desc="Data Methods">
  const UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          avatarUrl == other.avatarUrl &&
          createdAt == other.createdAt &&
          role == other.role);

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      avatarUrl.hashCode ^
      createdAt.hashCode ^
      role.hashCode;

  @override
  String toString() {
    return 'UserModel{' +
        ' id: $id,' +
        ' email: $email,' +
        ' fullName: $fullName,' +
        ' avatarUrl: $avatarUrl,' +
        ' createdAt: $createdAt,' +
        ' role: $role,' +
        '}';
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'email': this.email,
      'fullName': this.fullName,
      'avatarUrl': this.avatarUrl,
      'createdAt': this.createdAt,
      'role': this.role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      avatarUrl: map['avatarUrl'] as String,
      createdAt: map['createdAt'] as DateTime,
      role: map['role'] as String,
    );
  }

  //</editor-fold>
}
