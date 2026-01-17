class ContentBlock {
  final String type;
  final String? data;
  final String? url;
  final String? caption;

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] ?? 'text',
      data: json['data'],
      url: json['url'],
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'url': url,
      'caption': caption,
    };
  }

  //<editor-fold desc="Data Methods">
  const ContentBlock({
    required this.type,
    this.data,
    this.url,
    this.caption,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentBlock &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          data == other.data &&
          url == other.url &&
          caption == other.caption);

  @override
  int get hashCode => type.hashCode ^ data.hashCode ^ url.hashCode ^ caption.hashCode;

  @override
  String toString() {
    return 'ContentBlock{' +
        ' type: $type,' +
        ' data: $data,' +
        ' url: $url,' +
        ' caption: $caption,' +
        '}';
  }

  ContentBlock copyWith({
    String? type,
    String? data,
    String? url,
    String? caption,
  }) {
    return ContentBlock(
      type: type ?? this.type,
      data: data ?? this.data,
      url: url ?? this.url,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': this.type,
      'data': this.data,
      'url': this.url,
      'caption': this.caption,
    };
  }

  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    return ContentBlock(
      type: map['type'] as String,
      data: map['data'] as String,
      url: map['url'] as String,
      caption: map['caption'] as String,
    );
  }

  //</editor-fold>
}

class LearningContent {
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
      id: json['id'],
      topicId: json['topic_id'] ?? 0,
      title: json['title'] ?? 'Không có tiêu đề',
      blocks: parsedBlocks,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  //<editor-fold desc="Data Methods">
  const LearningContent({
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
        ' id: $id,' +
        ' topicId: $topicId,' +
        ' title: $title,' +
        ' blocks: $blocks,' +
        ' createdAt: $createdAt,' +
        '}';
  }

  LearningContent copyWith({
    int? id,
    int? topicId,
    String? title,
    List<ContentBlock>? blocks,
    DateTime? createdAt,
  }) {
    return LearningContent(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'topicId': this.topicId,
      'title': this.title,
      'blocks': this.blocks,
      'createdAt': this.createdAt,
    };
  }

  factory LearningContent.fromMap(Map<String, dynamic> map) {
    return LearningContent(
      id: map['id'] as int,
      topicId: map['topicId'] as int,
      title: map['title'] as String,
      blocks: map['blocks'] as List<ContentBlock>,
      createdAt: map['createdAt'] as DateTime,
    );
  }

  //</editor-fold>
}
