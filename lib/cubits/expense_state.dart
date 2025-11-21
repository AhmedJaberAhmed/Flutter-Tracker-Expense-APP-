import 'package:tracker/models/expense_item.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseSuccess extends ExpenseState {
  final List<ExpenseItem> expenses;

  ExpenseSuccess(this.expenses);
}

class ExpenseFailure extends ExpenseState {
  final String message;

  ExpenseFailure(this.message);
}
