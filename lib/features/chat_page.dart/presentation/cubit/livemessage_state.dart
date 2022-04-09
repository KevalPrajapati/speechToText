part of 'livemessage_cubit.dart';

@freezed
class LiveMessageState with _$LiveMessageState {
  const factory LiveMessageState({
    required Map<String, List<String>> messages,
    required Map<String, bool> isFailedMap,
    required Option<File> recordingFile,
    required bool isRecording,
    required String currentChatId,
    required Option<String> speech,
    required bool isSttInitialized,
  }) = _LiveMessageState;

  factory LiveMessageState.initial() => LiveMessageState(
        messages: {},
        isFailedMap: {},
        isRecording: false,
        isSttInitialized: false,
        currentChatId: '',
        speech: none(),
        recordingFile: none(),
      );
}
