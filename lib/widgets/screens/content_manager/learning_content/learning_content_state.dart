import '../../../../common/enum/load_status.dart';
import '../../../../models/learning_content.dart';

class LearningState {
  final LoadStatus status;
  final List<LearningContent> contents;
  final String? errorMessage;

  const LearningState({
    this.status = LoadStatus.Init,
    this.contents = const [],
    this.errorMessage,
  });

  LearningState copyWith({
    LoadStatus? status,
    List<LearningContent>? contents,
    String? errorMessage,
  }) {
    return LearningState(
      status: status ?? this.status,
      contents: contents ?? this.contents,
      errorMessage: errorMessage,
    );
  }
}
