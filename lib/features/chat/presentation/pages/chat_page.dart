// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../cubit/livemessage_cubit.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.chatId}) : super(key: key);
  final String chatId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  File? file;
  late String path;
  final cubit = LiveMessageCubit();
  Timer? recordingTimer;
  bool isPlaying = false;
  @override
  void initState() {
    super.initState();
    cubit.emit(cubit.state.copyWith(currentChatId: widget.chatId));
    cubit.initChat();
    cubit.fetchMessageHistory();
  }

  stt.SpeechToText speech = stt.SpeechToText();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LiveMessageCubit, LiveMessageState>(
        bloc: cubit,
        builder: (context, state) {
          print("chatId stuff: ${state.currentChatId}");
          return Column(
            children: [
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              Text("${state.speech.fold(() => null, (a) => a)}"),
              RawMaterialButton(
                splashColor: Colors.transparent,
                onPressed: () {
                  toggleRecording(isRecording: state.isRecording);
                },
                elevation: 2.0,
                fillColor: Colors.grey,
                child: Icon(
                  state.isRecording ? Icons.stop : Icons.mic,
                  size: 25.0,
                  color: Colors.red,
                ),
                // padding: EdgeInsets.all(5),
                shape: CircleBorder(),
                constraints: BoxConstraints.expand(
                  width: 50,
                  height: 50,
                ),
              ),
              IconButton(
                onPressed: () {
                  cubit.stopStt();
                },
                icon: Icon(Icons.stop),
              ),
              if (state.messages[widget.chatId] != null)
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.messages[widget.chatId]!.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[widget.chatId]![index];
                      return ListTile(
                        leading: msg.isBot ? CircleAvatar() : null,
                        trailing: msg.isBot ? null : CircleAvatar(),
                        title: Text(msg.message),
                      );
                    },
                  ),
                )
            ],
          );
        },
      ),
    );
  }

  void toggleRecording({required bool isRecording}) async {
    cubit.toText();
  }

  @override
  void dispose() async {
    _recorder.closeRecorder();
    _player.closePlayer();
    cubit.stopStt();
    super.dispose();
  }
}
