// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../cubit/livemessage_cubit.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.chatId}) : super(key: key);
  final String chatId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  File? file;
  late String path;
  final cubit = LiveMessageCubit();
  Timer? recordingTimer;
  bool isPlaying = false;
  @override
  void initState() {
    super.initState();

    cubit.initChat(widget.chatId);
  }

  stt.SpeechToText speech = stt.SpeechToText();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LiveMessageCubit, LiveMessageState>(
        bloc: cubit,
        builder: (context, state) {
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
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: msg.isBot
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          if (msg.isBot) CircleAvatar(),
                          Flexible(
                            child: Text(
                              msg.message,
                              style: TextStyle(
                                color: msg.isBot ? Colors.blue : Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          if (!msg.isBot) CircleAvatar(),
                        ],
                      ),
                    );
                  },
                ),
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
              SizedBox(
                height: 20,
              )
            ],
          );
        },
      ),
    );
  }

  void toggleRecording({required bool isRecording}) async {
    if (isRecording) {
      cubit.stopStt();
      return;
    }
    cubit.startSpeechRecog();
  }

  @override
  void dispose() async {
    cubit.stopStt();
    super.dispose();
  }
}
