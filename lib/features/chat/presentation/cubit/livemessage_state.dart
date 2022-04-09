part of 'livemessage_cubit.dart';

@freezed
class LiveMessageState with _$LiveMessageState {
  const factory LiveMessageState({
    required List<Message> messages,
    required Map<String, bool> isFailedMap,
    required bool isRecording,
    required String currentChatId,
    required Option<String> speech,
    required String botQuestion,
    required String expectedText,
    required bool isSttInitialized,
  }) = _LiveMessageState;

  factory LiveMessageState.initial() => LiveMessageState(
        messages: [],
        isFailedMap: {},
        isRecording: false,
        isSttInitialized: false,
        expectedText: "",
        botQuestion: "",
        currentChatId: '',
        speech: none(),
      );
}
