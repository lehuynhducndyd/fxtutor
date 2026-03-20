part of 'topic_cubit.dart';

class TopicState {
  final List<TopicModel> listTopic;
  final List<TopicModel> availableTopic;
  final int selectedIdx;
  final LoadStatus loadStatus;
  final String searchQuery; // Thêm từ khóa tìm kiếm

  factory TopicState.initial() {
    return const TopicState(
      listTopic: [],
      availableTopic: [],
      selectedIdx: 0,
      loadStatus: LoadStatus.Init,
      searchQuery: '', // Giá trị mặc định
    );
  }

  //<editor-fold desc="Data Methods">
  const TopicState({
    required this.listTopic,
    required this.availableTopic,
    required this.selectedIdx,
    required this.loadStatus,
    required this.searchQuery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicState &&
          runtimeType == other.runtimeType &&
          listTopic == other.listTopic &&
          availableTopic == other.availableTopic &&
          selectedIdx == other.selectedIdx &&
          loadStatus == other.loadStatus &&
          searchQuery == other.searchQuery);

  @override
  int get hashCode =>
      listTopic.hashCode ^
      availableTopic.hashCode ^
      selectedIdx.hashCode ^
      loadStatus.hashCode ^
      searchQuery.hashCode;

  @override
  String toString() {
    return 'TopicState{' +
        ' listTopic: $listTopic,' +
        ' availableTopic: $availableTopic,' +
        ' selectedIdx: $selectedIdx,' +
        ' loadStatus: $loadStatus,' +
        ' searchQuery: $searchQuery,' +
        '}';
  }

  TopicState copyWith({
    List<TopicModel>? listTopic,
    List<TopicModel>? availableTopic,
    int? selectedIdx,
    LoadStatus? loadStatus,
    String? searchQuery,
  }) {
    return TopicState(
      listTopic: listTopic ?? this.listTopic,
      availableTopic: availableTopic ?? this.availableTopic,
      selectedIdx: selectedIdx ?? this.selectedIdx,
      loadStatus: loadStatus ?? this.loadStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listTopic': this.listTopic,
      'availableTopic': this.availableTopic,
      'selectedIdx': this.selectedIdx,
      'loadStatus': this.loadStatus,
      'searchQuery': this.searchQuery,
    };
  }

  factory TopicState.fromMap(Map<String, dynamic> map) {
    return TopicState(
      listTopic: map['listTopic'] as List<TopicModel>,
      availableTopic: map['availableTopic'] as List<TopicModel>,
      selectedIdx: map['selectedIdx'] as int,
      loadStatus: map['loadStatus'] as LoadStatus,
      searchQuery: map['searchQuery'] as String,
    );
  }

  //</editor-fold>
}
