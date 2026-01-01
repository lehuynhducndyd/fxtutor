part of 'guide_manage_cubit.dart';

class GuideManageState {
  final LoadStatus status;
  final List<CalculatorGuideModel> guides;
  final String? errorMessage;
  final String? successMessage;

  //<editor-fold desc="Data Methods">
  const GuideManageState({
    required this.status,
    required this.guides,
    this.errorMessage,
    this.successMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuideManageState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          guides == other.guides &&
          errorMessage == other.errorMessage &&
          successMessage == other.successMessage);

  @override
  int get hashCode =>
      status.hashCode ^ guides.hashCode ^ errorMessage.hashCode ^ successMessage.hashCode;

  @override
  String toString() {
    return 'GuideManageState{' +
        ' status: $status,' +
        ' guides: $guides,' +
        ' errorMessage: $errorMessage,' +
        ' successMessage: $successMessage,' +
        '}';
  }

  GuideManageState copyWith({
    LoadStatus? status,
    List<CalculatorGuideModel>? guides,
    String? errorMessage,
    String? successMessage,
  }) {
    return GuideManageState(
      status: status ?? this.status,
      guides: guides ?? this.guides,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': this.status,
      'guides': this.guides,
      'errorMessage': this.errorMessage,
      'successMessage': this.successMessage,
    };
  }

  factory GuideManageState.fromMap(Map<String, dynamic> map) {
    return GuideManageState(
      status: map['status'] as LoadStatus,
      guides: map['guides'] as List<CalculatorGuideModel>,
      errorMessage: map['errorMessage'] as String,
      successMessage: map['successMessage'] as String,
    );
  }

  //</editor-fold>
}
