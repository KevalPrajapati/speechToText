import 'package:bloc/bloc.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../repo/dashboard_repo.dart';
part 'dashboard_cubit.freezed.dart';
part 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState.loading());
  final _repo = DashboardRepo();
  Future<void> fetchChats() async {
    emit(DashboardState.loading());
    final chats = await _repo.getChats();
    print(chats);
    emit(DashboardState.success(chats));
  }

  Future<void> addNewChat(String chatId) async {
    emit(DashboardState.loading());
    final stateChats = state.map<List<String>>(
        loading: (s) => [], failed: (f) => [], success: (s) => s.chats);
    emit(DashboardState.success(stateChats..add(chatId)));
  }
}
