import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendbuddy/widgets/chart/chat.dart';
import 'package:spendbuddy/widgets/expenses_list/expenses_list.dart';
import 'package:spendbuddy/models/expense.dart';
import 'package:spendbuddy/widgets/monthly.dart';
import 'package:spendbuddy/widgets/new_expense.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [
    Expense(
        title: 'Flutter Course',
        amount: 19.99,
        date: DateTime.now(),
        category: Category.work),
    Expense(
        title: 'Food',
        amount: 15.99,
        date: DateTime.now(),
        category: Category.leisure),
  ];

  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    initSharedPrefrences();

    super.initState();
  }

  initSharedPrefrences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  void saveData() {
    List<String> spList =
        _registeredExpenses.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('savedlist', spList);
  }

  void loadData() {
    List<String> spList = sharedPreferences.getStringList('savedlist')!;

    _registeredExpenses =
        spList.map((item) => Expense.fromMap(json.decode(item))).toList();

    setState(() {});
  }

  void _openAddExpensesOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return NewExpense(onAddExpense: _addExpense);
      },
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
      saveData();
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text(
          'Expense deleted',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(
              () {
                _registeredExpenses.insert(expenseIndex, expense);
              },
            );
          },
        ),
      ),
    );
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('S P E N D B U D D Y'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: _openAddExpensesOverlay,
                icon: const Icon(Icons.add)),
          )
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registeredExpenses),
                Expanded(
                  child: Column(
                    children: [
                      Monthly(expenses: _registeredExpenses),
                      Expanded(child: mainContent),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Chart(expenses: _registeredExpenses),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Monthly(expenses: _registeredExpenses),
                      Expanded(child: mainContent),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
