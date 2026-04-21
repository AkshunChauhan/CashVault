import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/categories.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';

/// Screen for adding a new income or expense transaction.
/// Designed for speed: ≤ 2 taps to add an entry.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _type = 'expense'; // Default to expense (most common action)
  String? _category;
  bool _isSaving = false;

  List<String> get _categories => Categories.forType(_type);

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = _type == 'add';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Type Toggle ───────────────────────────────────
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
                    _buildTypeButton(
                      label: 'Expense',
                      value: 'expense',
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.expense,
                      isSelected: !isIncome,
                      theme: theme,
                    ),
                    _buildTypeButton(
                      label: 'Income',
                      value: 'add',
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.income,
                      isSelected: isIncome,
                      theme: theme,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Amount Input ──────────────────────────────────
              Text(
                'Amount',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                  color: isIncome ? AppTheme.income : AppTheme.expense,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    color: isIncome ? AppTheme.income : AppTheme.expense,
                  ),
                  hintText: '0.00',
                  hintStyle: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an amount';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── Category ──────────────────────────────────────
              Text(
                'Category',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                decoration: const InputDecoration(),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() => _category = value);
                },
              ),

              const SizedBox(height: 24),

              // ── Note (optional) ───────────────────────────────
              Text(
                'Note (optional)',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a note...',
                  counterText: '',
                ),
              ),

              const SizedBox(height: 32),

              // ── Save Button ───────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = value;
            _category = _categories.first;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : theme.textTheme.bodyMedium?.color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final service = context.read<TransactionService>();
    await service.addTransaction(
      amount: double.parse(_amountController.text),
      type: _type,
      category: _category ?? 'Other',
      note: _noteController.text,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
