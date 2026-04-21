import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Displays the total balance with income/expense breakdown.
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatter.format(balance),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimary,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _BalanceSummaryItem(
                icon: Icons.arrow_upward_rounded,
                label: 'Income',
                amount: formatter.format(income),
                color: AppTheme.income,
                textColor: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 24),
              _BalanceSummaryItem(
                icon: Icons.arrow_downward_rounded,
                label: 'Expenses',
                amount: formatter.format(expenses),
                color: const Color(0xFFEF4444),
                textColor: theme.colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceSummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;
  final Color textColor;

  const _BalanceSummaryItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
