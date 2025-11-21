

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/expense_item.dart';

class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("expenses.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount TEXT NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertExpense(ExpenseItem expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseItem>> fetchExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: "dateTime DESC");
    return result.map((e) => ExpenseItem.fromMap(e)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
