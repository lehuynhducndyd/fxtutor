part of 'topic_cubit.dart';

class TopicState {
  final List<TopicModel> listTopic;
  final int selectedIdx;
  final LoadStatus loadStatus;
  final String searchQuery; // Thêm từ khóa tìm kiếm

  factory TopicState.initial() {
    return const TopicState(
      listTopic: [],
      selectedIdx: 0,
      loadStatus: LoadStatus.Init,
      searchQuery: '', // Giá trị mặc định
    );
  }

  //<editor-fold desc="Data Methods">
  const TopicState({
    required this.listTopic,
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
          selectedIdx == other.selectedIdx &&
          loadStatus == other.loadStatus &&
          searchQuery == other.searchQuery);

  @override
  int get hashCode =>
      listTopic.hashCode ^ selectedIdx.hashCode ^ loadStatus.hashCode ^ searchQuery.hashCode;

  @override
  String toString() {
    return 'TopicState{' +
        ' listTopic: $listTopic,' +
        ' selectedIdx: $selectedIdx,' +
        ' loadStatus: $loadStatus,' +
        ' searchQuery: $searchQuery,' +
        '}';
  }

  TopicState copyWith({
    List<TopicModel>? listTopic,
    int? selectedIdx,
    LoadStatus? loadStatus,
    String? searchQuery,
  }) {
    return TopicState(
      listTopic: listTopic ?? this.listTopic,
      selectedIdx: selectedIdx ?? this.selectedIdx,
      loadStatus: loadStatus ?? this.loadStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listTopic': this.listTopic,
      'selectedIdx': this.selectedIdx,
      'loadStatus': this.loadStatus,
      'searchQuery': this.searchQuery,
    };
  }

  factory TopicState.fromMap(Map<String, dynamic> map) {
    return TopicState(
      listTopic: map['listTopic'] as List<TopicModel>,
      selectedIdx: map['selectedIdx'] as int,
      loadStatus: map['loadStatus'] as LoadStatus,
      searchQuery: map['searchQuery'] as String? ?? '',
    );
  }
  //</editor-fold>
}
