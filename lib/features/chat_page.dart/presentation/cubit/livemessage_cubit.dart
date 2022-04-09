import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
part 'livemessage_cubit.freezed.dart';
part 'livemessage_state.dart';

@injectable
class LiveMessageCubit extends Cubit<LiveMessageState> {
  LiveMessageCubit() : super(LiveMessageState.initial());

  toggleRecording() {
    emit(state.copyWith(isRecording: !state.isRecording));
  }

  onFileChanged(File file) {
    emit(state.copyWith(recordingFile: some(file)));
  }

  // onSpeechChanged(String speech) {
  //   emit(state.copyWith(speech: some(speech)));
  // }

  stopStt() {
    print(speech.lastRecognizedWords);
    print(speech.lastStatus);
    speech.stop();
    emit(state.copyWith(speech: some(speech.lastRecognizedWords)));
    var messages = state.messages;
    var messagesList = messages[state.currentChatId] ?? [];
    messages.addAll({
      '${state.currentChatId}': messagesList..add(speech.lastRecognizedWords),
    });
    // emit(state.copyWith(messages:);
  }

  initializeStt() async {
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
  toText() async {
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
}
