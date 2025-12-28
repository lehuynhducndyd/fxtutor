part of 'topic_cubit.dart';

class TopicState {
  final List<TopicModel> listTopic;
  final int selectedIdx;
  final LoadStatus loadStatus;

  factory TopicState.initial() {
    return TopicState(
      listTopic: [],
      selectedIdx: 0,
      loadStatus: LoadStatus.Init,
    );
  }

  //<editor-fold desc="Data Methods">
  const TopicState({
    required this.listTopic,
    required this.selectedIdx,
    required this.loadStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicState &&
          runtimeType == other.runtimeType &&
          listTopic == other.listTopic &&
          selectedIdx == other.selectedIdx &&
          loadStatus == other.loadStatus);

  @override
  int get hashCode => listTopic.hashCode ^ selectedIdx.hashCode ^ loadStatus.hashCode;

  @override
  String toString() {
    return 'TopicState{' +
        ' listTopic: $listTopic,' +
        ' selectedIdx: $selectedIdx,' +
        ' loadStatus: $loadStatus,' +
        '}';
  }

  TopicState copyWith({
    List<TopicModel>? listTopic,
    int? selectedIdx,
    LoadStatus? loadStatus,
  }) {
    return TopicState(
      listTopic: listTopic ?? this.listTopic,
      selectedIdx: selectedIdx ?? this.selectedIdx,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listTopic': this.listTopic,
      'selectedIdx': this.selectedIdx,
      'loadStatus': this.loadStatus,
    };
  }

  factory TopicState.fromMap(Map<String, dynamic> map) {
    return TopicState(
      listTopic: map['listTopic'] as List<TopicModel>,
      selectedIdx: map['selectedIdx'] as int,
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }

  //</editor-fold>
}
