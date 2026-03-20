class ContentBlock {
  final String type;
  final String? data;
  final String? url;
  final String? caption;

  // === THÊM CÁC THUỘC TÍNH STYLE CHO TEXT ===
  final bool? isBold;
  final bool? isItalic;
  final bool? isUnderline;
  final String? color;
  final String? fontSize;

  const ContentBlock({
    required this.type,
    this.data,
    this.url,
    this.caption,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.color = 'black',
    this.fontSize = 'medium',
  });

  // Chuyển từ JSON (trên DB) thành Object trong App
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] as String,
      data: json['data'] as String?,
      url: json['url'] as String?,
      caption: json['caption'] as String?,
      // Lấy dữ liệu style lên, nếu không có thì set giá trị mặc định
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      color: json['color'] as String? ?? 'black',
      fontSize: json['fontSize'] as String? ?? 'medium',
    );
  }

  // Chuyển từ Object trong App thành JSON để lưu xuống DB
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'url': url,
      'caption': caption,
      // Cực kỳ tối ưu: Chỉ lưu các trường style này nếu khối đó là 'text'
      if (type == 'text') 'isBold': isBold,
      if (type == 'text') 'isItalic': isItalic,
      if (type == 'text') 'isUnderline': isUnderline,
      if (type == 'text') 'color': color,
      if (type == 'text') 'fontSize': fontSize,
    };
  }

  // Hàm copyWith để dễ dàng update UI khi bấm nút đổi màu/đổi size
  ContentBlock copyWith({
    String? type,
    String? data,
    String? url,
    String? caption,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    String? color,
    String? fontSize,
  }) {
    return ContentBlock(
      type: type ?? this.type,
      data: data ?? this.data,
      url: url ?? this.url,
      caption: caption ?? this.caption,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class LearningContent {
  final String? userId;
  final int id;
  final int topicId;
  final String title;
  final List<ContentBlock> blocks;
  final DateTime createdAt;

  factory LearningContent.fromJson(Map<String, dynamic> json) {
    var listRaw = json['content'] as List<dynamic>? ?? [];
    List<ContentBlock> parsedBlocks = listRaw
        .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
        .toList();

    return LearningContent(
      userId: json['user_id'] ?? "",
      id: json['id'],
      topicId: json['topic_id'] ?? 0,
      title: json['title'] ?? 'Không có tiêu đề',
      blocks: parsedBlocks,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  //<editor-fold desc="Data Methods">
  const LearningContent({
    this.userId,
    required this.id,
    required this.topicId,
    required this.title,
    required this.blocks,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningContent &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          id == other.id &&
          topicId == other.topicId &&
          title == other.title &&
          blocks == other.blocks &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^ topicId.hashCode ^ title.hashCode ^ blocks.hashCode ^ createdAt.hashCode;

  @override
  String toString() {
    return 'LearningContent{' +
        ' userId: $userId,' +
        ' id: $id,' +
        ' topicId: $topicId,' +
        ' title: $title,' +
        ' blocks: $blocks,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  LearningContent copyWith({
    String? userId,
    int? id,
    int? topicId,
    String? title,
    List<ContentBlock>? blocks,
    DateTime? createdAt,
  }) {
    return LearningContent(
      userId: userId,
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': this.userId,
      'id': this.id,
      'topicId': this.topicId,
      'title': this.title,
      'blocks': this.blocks,
      'createdAt': this.createdAt,
    };
  }

  factory LearningContent.fromMap(Map<String, dynamic> map) {
    return LearningContent(
      userId: map['userId'] as String,
      id: map['id'] as int,
      topicId: map['topicId'] as int,
      title: map['title'] as String,
      blocks: map['blocks'] as List<ContentBlock>,
      createdAt: map['createdAt'] as DateTime,
    );
  }

  //</editor-fold>
}
