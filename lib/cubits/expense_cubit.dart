import 'package:flutter_bloc/flutter_bloc.dart';
import '../database_helper.dart';
import '../date_time/date_time_helper.dart';
import '../models/expense_item.dart';

import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit() : super(ExpenseInitial());

  void loadExpenses() async {
    try {
      emit(ExpenseLoading());
      final expenses = await ExpenseDatabase.instance.fetchExpenses();
      emit(ExpenseSuccess(expenses));
    } catch (e) {
      emit(ExpenseFailure(e.toString()));
    }
  }


  void addExpense(ExpenseItem expense) async {
    await ExpenseDatabase.instance.insertExpense(expense);
    loadExpenses();
  }

  void deleteExpense(int id) async {
    await ExpenseDatabase.instance.deleteExpense(id);
    loadExpenses();
  }

  Map<String, double> calculateDailyExpenseSummary(List<ExpenseItem> expenses) {
    Map<String, double> dailyExpenseSummary = {};
    for (var expense in expenses) {
      String date = convertDateToString(expense.dateTime);
      double amount = double.tryParse(expense.amount) ?? 0;
      dailyExpenseSummary.update(date, (val) => val + amount, ifAbsent: () => amount);
    }
    return dailyExpenseSummary;
  }
}
