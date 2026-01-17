import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/learning_content_service.dart';
import 'learning_content_state.dart';

class LearningCubit extends Cubit<LearningState> {
  final LearningService _service;

  LearningCubit(this._service) : super(const LearningState());

  Future<void> loadContents(int topicId) async {
    emit(state.copyWith(status: LoadStatus.Loading));

    try {
      final data = await _service.fetchContentsByTopic(topicId);

      emit(
        state.copyWith(
          status: LoadStatus.Done,
          contents: data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LoadStatus.Error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
