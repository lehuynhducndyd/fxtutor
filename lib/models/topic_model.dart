class TopicModel {
  final int id;
  final String? userId;
  final String title;
  final String description;
  final DateTime? createdAt;

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'user_id': userId,
    };
  }

  //<editor-fold desc="Data Methods">
  const TopicModel({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          title == other.title &&
          description == other.description &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ title.hashCode ^ description.hashCode ^ createdAt.hashCode;

  @override
  String toString() {
    return 'TopicModel{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' title: $title,' +
        ' description: $description,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  TopicModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return TopicModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'title': this.title,
      'description': this.description,
      'createdAt': this.createdAt,
    };
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] as int,
      userId: map['userId'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: map['createdAt'] as DateTime,
    );
  }

  //</editor-fold>
}
