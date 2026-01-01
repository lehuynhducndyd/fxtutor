class CalculatorGuideModel {
  final int? id;
  final String actionName;
  final List<String> compatibleModels;
  final List<GuideMethod> methods;

  factory CalculatorGuideModel.fromJson(Map<String, dynamic> json) {
    return CalculatorGuideModel(
      id: json['id'],
      actionName: json['action_name'] ?? '',
      compatibleModels: List<String>.from(json['compatible_models'] ?? []),
      methods:
          (json['methods'] as List<dynamic>?)?.map((e) => GuideMethod.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_name': actionName,
      'compatible_models': compatibleModels,
      'methods': methods.map((e) => e.toJson()).toList(),
    };
  }

  //<editor-fold desc="Data Methods">
  const CalculatorGuideModel({
    this.id,
    required this.actionName,
    required this.compatibleModels,
    required this.methods,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalculatorGuideModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          actionName == other.actionName &&
          compatibleModels == other.compatibleModels &&
          methods == other.methods);

  @override
  int get hashCode =>
      id.hashCode ^ actionName.hashCode ^ compatibleModels.hashCode ^ methods.hashCode;

  @override
  String toString() {
    return 'CalculatorGuideModel{' +
        ' id: $id,' +
        ' actionName: $actionName,' +
        ' compatibleModels: $compatibleModels,' +
        ' methods: $methods,' +
        '}';
  }

  CalculatorGuideModel copyWith({
    int? id,
    String? actionName,
    List<String>? compatibleModels,
    List<GuideMethod>? methods,
  }) {
    return CalculatorGuideModel(
      id: id ?? this.id,
      actionName: actionName ?? this.actionName,
      compatibleModels: compatibleModels ?? this.compatibleModels,
      methods: methods ?? this.methods,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'actionName': this.actionName,
      'compatibleModels': this.compatibleModels,
      'methods': this.methods,
    };
  }

  factory CalculatorGuideModel.fromMap(Map<String, dynamic> map) {
    return CalculatorGuideModel(
      id: map['id'] as int,
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
