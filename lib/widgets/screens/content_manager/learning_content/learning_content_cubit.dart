import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../models/learning_content.dart';
import '../../../../services/learning_content_service.dart';
import 'learning_content_state.dart';

class LearningCubit extends Cubit<LearningState> {
  final LearningService _service;

  int _currentTopicId = 0;

  LearningCubit(this._service) : super(const LearningState(status: LoadStatus.Init, contents: []));

  Future<void> loadContents(int topicId) async {
    _currentTopicId = topicId; // Lưu lại ID
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      final data = await _service.fetchContentsByTopic(topicId);
      emit(state.copyWith(status: LoadStatus.Done, contents: data));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: e.toString()));
    }
  }

  Future<void> addLesson(String title, List<ContentBlock> blocks) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      await _service.createContent(topicId: _currentTopicId, title: title, blocks: blocks);
      // Reload lại danh sách
      await loadContents(_currentTopicId);
      // Emit success message
      emit(state.copyWith(successMessage: "Thêm bài học thành công!"));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: e.toString()));
    }
  }

  Future<void> updateLesson(int id, String title, List<ContentBlock> blocks) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      await _service.updateContent(id: id, title: title, blocks: blocks);
      await loadContents(_currentTopicId);
      emit(state.copyWith(successMessage: "Cập nhật thành công!"));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: e.toString()));
    }
  }

  Future<void> deleteLesson(int id) async {
    emit(state.copyWith(status: LoadStatus.Loading));
    try {
      await _service.deleteContent(id);
      await loadContents(_currentTopicId);
      emit(state.copyWith(successMessage: "Đã xóa bài học!"));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.Error, errorMessage: e.toString()));
    }
  }
}
