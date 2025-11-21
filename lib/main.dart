import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 import 'package:tracker/pages/home.dart';

import 'cubits/expense_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpenseCubit()..loadExpenses(),
      child: const MaterialApp(debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
