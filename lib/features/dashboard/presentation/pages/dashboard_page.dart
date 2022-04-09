import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../chat/presentation/pages/chat_page.dart';
import '../cubit/dashboard_cubit.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = DashboardCubit()..fetchChats();
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Column(
        children: [
          BlocBuilder<DashboardCubit, DashboardState>(
            bloc: cubit,
            builder: (context, state) {
              return state.maybeMap(
                loading: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
                orElse: () => const Center(
                  child: Text('No data'),
                ),
                success: (s) {
                  if (s.chats.isEmpty) {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: s.chats.length,
                    itemBuilder: (context, index) {
                      final chat = s.chats[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChatPage(chatId: chat)));
                        },
                        title: Text(chat),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          cubit.addNewChat("restaurant");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(chatId: 'restaurant')));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
