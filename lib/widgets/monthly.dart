import 'package:flutter/material.dart';
import 'package:spendbuddy/models/expense.dart';

class Monthly extends StatefulWidget {
  const Monthly({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  State<Monthly> createState() => _MonthlyState();
}

class _MonthlyState extends State<Monthly> {
  double get monthlyExpenses {
    double money = 0;

    for (final expense in widget.expenses) {
      setState(() {
        if (expense.date.month == DateTime.now().month) {
          money = money + expense.amount;
        }
      });
    }

    return money;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.primary.withOpacity(0.0)
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Text(
        'Total Spent this Month : ₹ $monthlyExpenses',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
