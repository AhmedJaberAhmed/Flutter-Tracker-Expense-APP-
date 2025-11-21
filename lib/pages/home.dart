import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import '../models/expense_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController newExpenseName = TextEditingController();
  final TextEditingController newExpenseAmount = TextEditingController();

  void addNewExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add new Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newExpenseName,
              decoration: const InputDecoration(labelText: "Expense Name"),
            ),
            TextField(
              controller: newExpenseAmount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: save,
            child: const Text("Save"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              clearControllers();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void save() {
    if (newExpenseName.text.isNotEmpty && newExpenseAmount.text.isNotEmpty) {
      final expense = ExpenseItem(
        name: newExpenseName.text,
        amount: newExpenseAmount.text,
        dateTime: DateTime.now(),
      );

      context.read<ExpenseCubit>().addExpense(expense);
    }

    Navigator.pop(context);
    clearControllers();
  }

  void clearControllers() {
    newExpenseName.clear();
    newExpenseAmount.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExpenseSuccess) {
              final cubit = context.read<ExpenseCubit>();
              final summary =
              cubit.calculateDailyExpenseSummary(state.expenses);

              // Calculate week total
              final weekTotal = summary.values.fold(0.0, (a, b) => a + b);

              // Max spending for chart scaling
              final maxSpending = summary.values.isEmpty
                  ? 0
                  : summary.values.reduce((a, b) => a > b ? a : b);

              // Weekdays (Sun → Sat)
              final weekdays = [
                "Sun",
                "Mon",
                "Tue",
                "Wed",
                "Thu",
                "Fri",
                "Sat"
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP SECTION
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Week Total: \$${weekTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Bar Chart
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < weekdays.length) {
                                  return Text(weekdays[index]);
                                }
                                return const Text("");
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(7, (index) {
                          final dayName = weekdays[index];
                          final spending = summary.entries
                              .firstWhere(
                                (e) =>
                            DateFormat('EEE')
                                .format(DateTime.parse(e.key)) ==
                                dayName,
                            orElse: () => MapEntry("", 0.0),
                          )
                              .value;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: maxSpending == 0 ? 0 : spending,
                                width: 18,
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxSpending.toDouble(),
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // MIDDLE SECTION: Transactions
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = state.expenses[index];
                        return Card(
                          color: Colors.grey[300], // 🔥 makes card gray
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12), // smoother corners
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: ListTile(
                            title: Text(
                              expense.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .black, // text stays dark for contrast
                              ),
                            ),
                            subtitle: Text(
                              "Date: ${DateFormat('dd / MM / yyyy').format(expense.dateTime)}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "\$${expense.amount}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.black),
                                  onPressed: () {
                                    context
                                        .read<ExpenseCubit>()
                                        .deleteExpense(expense.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("No data"));
          },
        ),
      ),

      // BOTTOM SECTION: FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: addNewExpenseDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}