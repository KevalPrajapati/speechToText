import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/dashboard_cubit.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = DashboardCubit();
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
                success: (s) => Text(s.chats.toString()),
              );
            },
          ),
        ],
      ),
    );
  }
}
