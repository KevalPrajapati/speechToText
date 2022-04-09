import 'package:shared_preferences/shared_preferences.dart';

class DashboardRepo {
  Future<List<String>> getChats() async {
    final _prefs = await SharedPreferences.getInstance();

    return _prefs.getStringList("chats") ?? [];
  }

  void addNewChat(String chatId) async {
    final _prefs = await SharedPreferences.getInstance();
    final chats = _prefs.getStringList("chats") ?? [];
    if (!chats.contains(chatId)) {
      _prefs.setStringList("chats", chats..add(chatId));
    }
  }
}
