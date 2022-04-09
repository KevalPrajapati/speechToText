import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    // TODO: implement initState
    super.initState();
    cubit.initializeStt();
    cubit.emit(cubit.state.copyWith(currentChatId: widget.chatId));
    // speech.initialize();
    // _recorder.openRecorder();
    // _player.openPlayer();
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
                  playRecording(start: !isPlaying);
                },
                icon: Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {
                  cubit.stopStt();
                },
                icon: Icon(Icons.play_arrow),
              ),
              Text("${state.messages}"),
              if (state.messages[widget.chatId] != null)
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.messages[widget.chatId]!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.messages[widget.chatId]![index]),
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
    // print(speech.lastRecognizedWords);
    // speech.listen(onResult: (r) {
    //   print(r.recognizedWords);
    //   print(r.toJson());
    // });
    // cubit.stopStt();
    return;

    if (!isRecording) {
      final micPermission = await Permission.microphone.request();
      if (micPermission.isDenied || micPermission.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Mic permission has been denied. Enable it from your phone's settings page to begin recording."),
          ),
        );
        return;
      }
    }
    var tempDir = await getTemporaryDirectory();
    path = '${tempDir.path}/recording.mp4';
    cubit.toggleRecording();

    if (isRecording) {
      _recorder.stopRecorder();
      file = File(path);
      if (file != null) {
        // cubit.onFileChanged(file!);
      }
    } else {
      recordingTimer = Timer(Duration(minutes: 5), () async {
        await _recorder.stopRecorder();
        file = File(path);
        cubit.toggleRecording();
        // cubit.onFileChanged(file!);
        print(
            "============================file is ${file!.path}===================");
      });

      await _recorder.startRecorder(toFile: path);
    }
  }

  void playRecording({required bool start}) {
    if (_player.isStopped) {
      _player.startPlayer(fromURI: path, whenFinished: () {});
    } else {
      _player.stopPlayer();
    }
  }

  @override
  void dispose() async {
    _recorder.closeRecorder();
    _player.closePlayer();
    cubit.stopStt();
    super.dispose();
  }
}
