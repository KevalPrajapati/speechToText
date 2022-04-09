import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat/data/models/chat.dart';
import '../data/models/Message.dart';
import '../data/models/chat.dart';

class ChatRepository {
  Future<List<Chat>> fetchFromNetwork(String chatId) async {
    final result = await http.get(Uri.parse(
        "https://my-json-server.typicode.com/tryninjastudy/dummyapi/db"));

    print(result.body);
    if (result.statusCode != 200) {
      throw Exception("Failed to fetch data");
    }
    var i = 0;
    print("chatId: $chatId");
    return (jsonDecode(result.body)["$chatId"] as List)
        .map((e) => Chat.fromJson(e, i++))
        .toList();
  }

  saveLocaly(String chatId) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      final chats = _prefs.getStringList("chats") ?? [];

      if (!_prefs.containsKey(chatId)) {
        _prefs.setStringList(chatId, chats..add(chatId));
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
