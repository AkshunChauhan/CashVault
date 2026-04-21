import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/debt_service.dart';
import '../theme/app_theme.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.watch<DebtService>();
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IOU Ledger'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _DebtSummaryCard(
                      title: 'They Owe Me',
                      amount: formatter.format(service.totalOwedToMe),
                      color: AppTheme.income,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DebtSummaryCard(
                      title: 'I Owe Them',
                      amount: formatter.format(service.totalIOwe),
                      color: AppTheme.expense,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (service.activeDebts.isEmpty && service.settledDebts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No active debts. Tap + to add one.'),
              ),
            )
          else ...[
            if (service.activeDebts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Active',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final debt = service.activeDebts[index];
                    return _DebtTile(debt: debt);
                  },
                  childCount: service.activeDebts.length,
                ),
              ),
            ],
            
            if (service.settledDebts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Settled',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final debt = service.settledDebts[index];
                    return _DebtTile(debt: debt);
                  },
                  childCount: service.settledDebts.length,
                ),
              ),
            ],
          ]
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDebtModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddDebtSheet(),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _DebtSummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelMedium?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(
            amount,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final dynamic debt;

  const _DebtTile({required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = debt.isLent ? AppTheme.income : AppTheme.expense;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Dismissible(
      key: Key(debt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<DebtService>().deleteDebt(debt.id);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: debt.isSettled ? Colors.grey.withValues(alpha: 0.2) : color.withValues(alpha: 0.2),
          child: Icon(
            debt.isLent ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: debt.isSettled ? Colors.grey : color,
          ),
        ),
        title: Text(
          debt.personName,
          style: TextStyle(
            decoration: debt.isSettled ? TextDecoration.lineThrough : null,
            color: debt.isSettled ? Colors.grey : null,
          ),
        ),
        subtitle: debt.dueDate != null
            ? Text(
                'Due: ${dateFormat.format(debt.dueDate)}',
                style: TextStyle(
                  color: (!debt.isSettled && debt.dueDate.isBefore(DateTime.now()))
                      ? Colors.red
                      : Colors.grey,
                ),
              )
            : const Text('No due date'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatter.format(debt.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: debt.isSettled ? Colors.grey : color,
              ),
            ),
            if (!debt.isSettled) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: AppTheme.income,
                onPressed: () {
                  context.read<DebtService>().markSettled(debt.id);
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _AddDebtSheet extends StatefulWidget {
  const _AddDebtSheet();

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'lend'; // lend or borrow
  DateTime? _dueDate;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = _type == 'lend';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add IOU', style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),

                // Type Toggle
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerTheme.color ?? Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = 'lend'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isIncome ? AppTheme.income.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                'I lent money',
                                style: TextStyle(
                                  color: isIncome ? AppTheme.income : theme.textTheme.bodyMedium?.color,
                                  fontWeight: isIncome ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = 'borrow'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isIncome ? AppTheme.expense.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                'I borrowed money',
                                style: TextStyle(
                                  color: !isIncome ? AppTheme.expense : theme.textTheme.bodyMedium?.color,
                                  fontWeight: !isIncome ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Person Name'),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date (Optional)'),
                  subtitle: Text(_dueDate == null ? 'No date set' : DateFormat('MMM d, yyyy').format(_dueDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<DebtService>().addDebt(
                        personName: _nameController.text.trim(),
                        amount: double.parse(_amountController.text),
                        type: _type,
                        dueDate: _dueDate,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
