import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../data/models/Message.dart';
import '../../data/models/chat.dart';
import '../../repo/chat_repository.dart';

part 'livemessage_cubit.freezed.dart';
part 'livemessage_state.dart';

@injectable
class LiveMessageCubit extends Cubit<LiveMessageState> {
  LiveMessageCubit() : super(LiveMessageState.initial());

  ChatRepository _repo = ChatRepository();

  initChat(String chatId) async {
    _repo.saveLocaly(state.currentChatId);
    emit(state.copyWith(
      currentChatId: chatId,
      messages: [],
      isFailedMap: {},
      isRecording: false,
      isSttInitialized: false,
      expectedText: "",
      botQuestion: "",
      speech: none(),
    ));
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
    emit(state.copyWith(speech: some(speech.lastRecognizedWords)));
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
    var _speechEnabled = await speech.initialize(
      finalTimeout: Duration(minutes: 5),
      onStatus: (s) {
        print("stt status changed $s");
        if (s == "listening") {
          emit(state.copyWith(isRecording: true));
        } else if (s == "done") {
          stopStt();
        } else {
          emit(state.copyWith(isRecording: false));
        }
      },
    );
    emit(state.copyWith(isSttInitialized: _speechEnabled));
  }

  stt.SpeechToText speech = stt.SpeechToText();
  void startSpeechRecog() async {
    print("trying t get speech ab bol");

    if (state.isSttInitialized) {
      speech.listen(
        onResult: (r) {
          print(r.recognizedWords);
          print(r.toJson());
          emit(state.copyWith(speech: some(r.recognizedWords)));
        },
      );
    } else {
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
