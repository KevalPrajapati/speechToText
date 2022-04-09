import 'package:flutter/material.dart';

import 'features/chat_page.dart/presentation/pages/chat_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Text',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(chatId: "sds"),
    );
  }
}
