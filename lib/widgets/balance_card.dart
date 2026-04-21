import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Displays the total balance with income/expense breakdown and Safe Inventory.
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;
  final Map<int, int> inventory;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
    required this.inventory,
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
          
          if (inventory.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.onPrimary.withValues(alpha: 0.1), height: 1),
            const SizedBox(height: 16),
            Text(
              'My Safe (Physical Bills)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: () {
                final entries = inventory.entries.toList();
                entries.sort((a, b) => b.key.compareTo(a.key)); // Highest bills first
                return entries.map((e) => _BillChip(
                  billValue: e.key,
                  count: e.value,
                  textColor: theme.colorScheme.onPrimary,
                )).toList();
              }(),
            ),
          ],
        ],
      ),
    );
  }
}

class _BillChip extends StatelessWidget {
  final int billValue;
  final int count;
  final Color textColor;

  const _BillChip({
    required this.billValue,
    required this.count,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '\$$billValue ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
            TextSpan(
              text: 'x$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
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
