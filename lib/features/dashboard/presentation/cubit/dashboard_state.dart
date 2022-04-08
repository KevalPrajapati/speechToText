part of 'dashboard_cubit.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.failed(String failure) = _Failed;
  const factory DashboardState.success(List<String> chats) = _Success;
}
