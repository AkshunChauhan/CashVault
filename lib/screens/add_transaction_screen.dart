import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/categories.dart';
import '../services/transaction_service.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _noteController = TextEditingController();
  final _otherAmountController = TextEditingController();
  
  // Available standard denomination bills to track
  final List<int> _availableBills = [100, 50, 20, 10, 5, 2, 1];
  
  // Stores bill_value -> count
  final Map<int, int> _denominations = {};
  
  // Controllers for the grid
  final Map<int, TextEditingController> _controllers = {};

  final _formKey = GlobalKey<FormState>();

  String _type = 'expense';
  String? _category;
  bool _isSaving = false;

  List<String> get _categories => Categories.forType(_type);

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
    for (var bill in _availableBills) {
      _controllers[bill] = TextEditingController();
    }
    _otherAmountController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _otherAmountController.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateTotal() {
    setState(() {}); // Re-computes the UI total getter
  }

  double get _totalAmount {
    double total = 0;
    _denominations.forEach((bill, count) {
      total += bill * count;
    });
    final other = double.tryParse(_otherAmountController.text) ?? 0.0;
    return total + other;
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

              // ── Computed Amount ───────────────────────────────
              Center(
                child: Text(
                  'Total Amount',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '\$${_totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    color: isIncome ? AppTheme.income : AppTheme.expense,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Denominations Grid ─────────────────────────────
              Text('Physical Bills', style: theme.textTheme.labelLarge),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableBills.map((bill) {
                  return _buildDenominationInput(bill, theme);
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── Coins / Other Amount ───────────────────────────
              Text('Coins / Other', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _otherAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                ),
              ),

              const SizedBox(height: 24),

              // ── Category ──────────────────────────────────────
              Text('Category', style: theme.textTheme.labelLarge),
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
              Text('Note (optional)', style: theme.textTheme.labelLarge),
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

  Widget _buildDenominationInput(int bill, ThemeData theme) {
    final count = _denominations[bill] ?? 0;
    final w = (MediaQuery.of(context).size.width - 40 - 24) / 3;

    return Container(
      width: w,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: count > 0 
            ? (_type == 'add' ? AppTheme.income : AppTheme.expense).withValues(alpha: 0.5) 
            : theme.dividerTheme.color ?? Colors.grey.shade200,
          width: count > 0 ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            '\$$bill',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: count > 0 ? (_type == 'add' ? AppTheme.income : AppTheme.expense) : null,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: TextField(
              controller: _controllers[bill],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Qty',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  final parsed = int.tryParse(val) ?? 0;
                  if (parsed > 0) {
                    _denominations[bill] = parsed;
                  } else {
                    _denominations.remove(bill);
                  }
                });
              },
            ),
          ),
        ],
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
    final total = _totalAmount;
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount greater than 0')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final otherAmount = double.tryParse(_otherAmountController.text) ?? 0.0;

    final service = context.read<TransactionService>();
    await service.addTransaction(
      amount: total,
      type: _type,
      category: _category ?? 'Other',
      note: _noteController.text,
      denominations: _denominations,
      otherAmount: otherAmount,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
