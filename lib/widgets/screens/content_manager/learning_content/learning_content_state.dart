import '../../../../common/enum/load_status.dart';
import '../../../../models/learning_content.dart';

class LearningState {
  final LoadStatus status;
  final List<LearningContent> contents;
  final String? errorMessage;
  final String? successMessage;

  //<editor-fold desc="Data Methods">
  const LearningState({
    required this.status,
    required this.contents,
    this.errorMessage,
    this.successMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          contents == other.contents &&
          errorMessage == other.errorMessage &&
          successMessage == other.successMessage);

  @override
  int get hashCode =>
      status.hashCode ^ contents.hashCode ^ errorMessage.hashCode ^ successMessage.hashCode;

  @override
  String toString() {
    return 'LearningState{' +
        ' status: $status,' +
        ' contents: $contents,' +
        ' errorMessage: $errorMessage,' +
        ' successMessage: $successMessage,' +
        '}';
  }

  LearningState copyWith({
    LoadStatus? status,
    List<LearningContent>? contents,
    String? errorMessage,
    String? successMessage,
  }) {
    return LearningState(
      status: status ?? this.status,
      contents: contents ?? this.contents,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': this.status,
      'contents': this.contents,
      'errorMessage': this.errorMessage,
      'successMessage': this.successMessage,
    };
  }

  factory LearningState.fromMap(Map<String, dynamic> map) {
    return LearningState(
      status: map['status'] as LoadStatus,
      contents: map['contents'] as List<LearningContent>,
      errorMessage: map['errorMessage'] as String,
      successMessage: map['successMessage'] as String,
    );
  }

  //</editor-fold>
}
