class ContributeModel {
  final String id;
  final String userId;
  final String content;
  final String status;
  final String? response;
  final DateTime createdAt;

  factory ContributeModel.fromJson(Map<String, dynamic> json) {
    return ContributeModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'pending',
      response: json['response'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  //<editor-fold desc="Data Methods">
  const ContributeModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.status,
    this.response,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContributeModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          content == other.content &&
          status == other.status &&
          response == other.response &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      content.hashCode ^
      status.hashCode ^
      response.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'ContributeModel{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' content: $content,' +
        ' status: $status,' +
        ' response: $response,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  ContributeModel copyWith({
    String? id,
    String? userId,
    String? content,
    String? status,
    String? response,
    DateTime? createdAt,
  }) {
    return ContributeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      status: status ?? this.status,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'content': this.content,
      'status': this.status,
      'response': this.response,
      'createdAt': this.createdAt,
    };
  }

  factory ContributeModel.fromMap(Map<String, dynamic> map) {
    return ContributeModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      status: map['status'] as String,
      response: map['response'] as String,
      createdAt: map['createdAt'] as DateTime,
    );
  }

  //</editor-fold>
}
