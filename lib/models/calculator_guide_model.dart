class CalculatorGuideModel {
  final String? userId;
  final int? id;
  final int topicId;
  final String actionName;
  final List<String> compatibleModels;
  final List<GuideMethod> methods;

  factory CalculatorGuideModel.fromJson(Map<String, dynamic> json) {
    return CalculatorGuideModel(
      userId: json['user_id'] ?? "",
      id: json['id'],
      topicId: json['topic_id'] ?? 0,
      actionName: json['action_name'] ?? '',
      compatibleModels: List<String>.from(json['compatible_models'] ?? []),
      methods:
          (json['methods'] as List<dynamic>?)?.map((e) => GuideMethod.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'topic_id': topicId,
      'action_name': actionName,
      'compatible_models': compatibleModels,
      'methods': methods.map((e) => e.toJson()).toList(),
    };

    // Chỉ thêm id vào map nếu nó khác null (dùng cho trường hợp Update)
    // Còn khi Insert (id là null) thì map sẽ không có key 'id'
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  //<editor-fold desc="Data Methods">

  const CalculatorGuideModel({
    this.userId,
    this.id,
    required this.topicId,
    required this.actionName,
    required this.compatibleModels,
    required this.methods,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalculatorGuideModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          id == other.id &&
          topicId == other.topicId &&
          actionName == other.actionName &&
          compatibleModels == other.compatibleModels &&
          methods == other.methods);

  @override
  int get hashCode =>
      userId.hashCode ^
      id.hashCode ^
      topicId.hashCode ^
      actionName.hashCode ^
      compatibleModels.hashCode ^
      methods.hashCode;

  @override
  String toString() {
    return 'CalculatorGuideModel{' +
        ' userId: $userId,' +
        ' id: $id,' +
        ' topicId: $topicId,' +
        ' actionName: $actionName,' +
        ' compatibleModels: $compatibleModels,' +
        ' methods: $methods,' +
        '}';
  }

  CalculatorGuideModel copyWith({
    String? userId,
    int? id,
    int? topicId,
    String? actionName,
    List<String>? compatibleModels,
    List<GuideMethod>? methods,
  }) {
    return CalculatorGuideModel(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      actionName: actionName ?? this.actionName,
      compatibleModels: compatibleModels ?? this.compatibleModels,
      methods: methods ?? this.methods,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': this.userId,
      'id': this.id,
      'topicId': this.topicId,
      'actionName': this.actionName,
      'compatibleModels': this.compatibleModels,
      'methods': this.methods,
    };
  }

  factory CalculatorGuideModel.fromMap(Map<String, dynamic> map) {
    return CalculatorGuideModel(
      userId: map['userId'] as String,
      id: map['id'] as int,
      topicId: map['topicId'] as int,
      actionName: map['actionName'] as String,
      compatibleModels: map['compatibleModels'] as List<String>,
      methods: map['methods'] as List<GuideMethod>,
    );
  }

  //</editor-fold>
}

class GuideMethod {
  final String methodName;
  final String content; // Nội dung chứa phím trong ngoặc [MENU]

  GuideMethod({required this.methodName, required this.content});

  factory GuideMethod.fromJson(Map<String, dynamic> json) {
    return GuideMethod(
      methodName: json['method_name'] ?? '',
      content: json['markdown_content'] ?? json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method_name': methodName,
      'markdown_content': content,
    };
  }
}
