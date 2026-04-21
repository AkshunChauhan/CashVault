import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

/// Displays a single transaction in the list.
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppTheme.income : AppTheme.expense;
    final sign = isIncome ? '+' : '-';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _categoryIcon(transaction.category),
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),

              // Category and note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.note?.isNotEmpty == true
                          ? transaction.note!
                          : (transaction.denominations.isNotEmpty
                              ? transaction.denominations.entries
                                  .map((e) => '${e.value}x \$${e.key}')
                                  .join(', ')
                              : dateFormat.format(transaction.createdAt)),
                      style: theme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${formatter.format(transaction.amount)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (transaction.note?.isNotEmpty == true)
                    Text(
                      dateFormat.format(transaction.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Maps category names to Material icons.
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Bills':
        return Icons.receipt_long_outlined;
      case 'Rent':
        return Icons.home_outlined;
      case 'Health':
        return Icons.favorite_outline;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Education':
        return Icons.school_outlined;
      case 'Salary':
        return Icons.work_outline;
      case 'Freelance':
        return Icons.laptop_outlined;
      case 'Gift':
        return Icons.card_giftcard_outlined;
      case 'Refund':
        return Icons.replay_outlined;
      default:
        return Icons.attach_money_outlined;
    }
  }
}
