import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fx_tutor/models/topic_model.dart';

import '../../../../common/enum/load_status.dart';
import '../../../../services/topic_service.dart';

part 'topic_state.dart';

class TopicCubit extends Cubit<TopicState> {
  final TopicService topicService;

  TopicCubit(this.topicService) : super(TopicState.initial());

  Future<void> loadTopics() async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      List<TopicModel> topics = await topicService.getTopics();
      emit(state.copyWith(listTopic: topics, loadStatus: LoadStatus.Done));
    } catch (e) {
      print(e);
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  Future<void> addTopic(String title, String description) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      await topicService.addTopic(title, description);
      await loadTopics();
      emit(state.copyWith(loadStatus: LoadStatus.Done));
    } catch (e) {
      print(e);
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  void setSelectedIdx(int idx) {
    emit(state.copyWith(selectedIdx: idx));
  }

  // HÀM MỚI: Cập nhật từ khóa tìm kiếm
  void searchTopic(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> updateTopic(String title, String description) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      await topicService.updateTopic(state.listTopic[state.selectedIdx].id, title, description);
      await loadTopics();
      emit(state.copyWith(loadStatus: LoadStatus.Done));
    } catch (e) {
      print(e);
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  Future<void> deleteTopic(int id) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      await topicService.deleteTopic(id);
      await loadTopics();
      emit(state.copyWith(loadStatus: LoadStatus.Done));
    } catch (e) {
      print(e);
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }
}
