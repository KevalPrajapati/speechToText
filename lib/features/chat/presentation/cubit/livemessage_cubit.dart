import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../data/models/Message.dart';
import '../../repo/chat_repository.dart';

part 'livemessage_cubit.freezed.dart';
part 'livemessage_state.dart';

class LiveMessageCubit extends Cubit<LiveMessageState> {
  LiveMessageCubit() : super(LiveMessageState.initial());

  final _repo = ChatRepository();
  stt.SpeechToText speech = stt.SpeechToText();

  initChat(String chatId) async {
    _repo.saveLocaly(state.currentChatId);
    emit(LiveMessageState.initial());
    emit(state.copyWith(currentChatId: chatId));
    fetchQuestion();
    await initializeStt();
  }

  fetchQuestion() async {
    final chats = await _repo.fetchFromNetwork(state.currentChatId);
    var nextIndex = 0;

    if (state.botQuestion.isNotEmpty) {
      print("index: $nextIndex");
      print(
          "expectedText: ${state.expectedText} botQuestion: ${state.botQuestion}");
      nextIndex = (chats
          .where((element) {
            print(element.bot == state.botQuestion);
            return element.bot == state.botQuestion;
          })
          .first
          .index);
      nextIndex++;
    }
    print("index: $nextIndex");

    final nextChat = chats[nextIndex];
    print(nextChat.toJson());
    var messages = state.messages;
    messages.add(
      Message(isBot: true, message: nextChat.bot!),
    );
    emit(
      state.copyWith(
        messages: messages,
        expectedText: nextChat.human!,
        botQuestion: nextChat.bot!,
      ),
    );
  }

  void stopStt() {
    print(speech.lastRecognizedWords);
    print(speech.lastStatus);
    speech.stop();
    emit(state.copyWith(
        speech: some(speech.lastRecognizedWords), isRecording: false));
    var messages = state.messages;
    print("${speech.lastRecognizedWords}");
    if (speech.lastRecognizedWords.isNotEmpty) {
      print("adding to list");
      messages.add(Message(isBot: false, message: speech.lastRecognizedWords));
    }
    emit(state.copyWith(messages: messages));
    onUserResponseComplete();
  }

  Future<void> initializeStt() async {
    speech.cancel();
    var _speechEnabled = await speech.initialize(
      finalTimeout: Duration(seconds: 10),
    );
    emit(state.copyWith(isSttInitialized: _speechEnabled));
  }

  void startSpeechRecog() async {
    if (state.isSttInitialized) {
      emit(state.copyWith(isRecording: true));
      speech.listen(
        onResult: (r) {
          emit(state.copyWith(speech: some(r.recognizedWords)));
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: "Speech to text not supported on this device or it is denied",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("The user has denied the use of speech recognition.");
    }
  }

  onUserResponseComplete() {
    print("user: ${state.speech}\n expected ${state.expectedText}");
    if (state.speech.fold(() => "", (a) => a).toLowerCase() ==
        state.expectedText.toLowerCase()) {
      print("fetching next");
      fetchQuestion();
    }
  }
}
