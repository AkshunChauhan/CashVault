import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';

/// Service for managing transactions in the local Hive database.
/// Extends ChangeNotifier so UI rebuilds on data changes.
class TransactionService extends ChangeNotifier {
  static const _boxName = 'transactions';

  Box<TransactionModel> get _box => Hive.box<TransactionModel>(_boxName);

  /// All transactions, sorted by most recent first.
  List<TransactionModel> get transactions {
    final list = _box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Current total balance.
  double get balance {
    return _box.values.fold(0.0, (sum, tx) => sum + tx.signedAmount);
  }

  /// Total income.
  double get totalIncome {
    return _box.values
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Total expenses.
  double get totalExpenses {
    return _box.values
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Number of transactions.
  int get count => _box.length;

  /// Map of current physical inventory (Bill Value -> Count).
  Map<int, int> get inventory {
    final inv = <int, int>{};
    for (var tx in _box.values) {
      tx.denominations.forEach((billValue, count) {
        if (tx.isIncome) {
          inv[billValue] = (inv[billValue] ?? 0) + count;
        } else {
          inv[billValue] = (inv[billValue] ?? 0) - count;
        }
      });
    }
    // Clean up 0s and ignore negatives for UI cleaniness (or let user fix their negative safe)
    return inv..removeWhere((k, v) => v == 0);
  }

  /// Adds a new transaction.
  Future<void> addTransaction({
    required double amount,
    required String type,
    required String category,
    String? note,
    Map<int, int> denominations = const {},
    double otherAmount = 0.0,
  }) async {
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      createdAt: DateTime.now(),
      denominations: denominations,
      otherAmount: otherAmount,
    );

    await _box.put(transaction.id, transaction);
    notifyListeners();
  }

  /// Deletes a transaction by ID.
  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Returns transactions for a specific date range.
  List<TransactionModel> getTransactionsInRange(DateTime start, DateTime end) {
    return transactions
        .where((tx) => tx.createdAt.isAfter(start) && tx.createdAt.isBefore(end))
        .toList();
  }

  /// Returns all transactions as maps (for potential sync export).
  List<Map<String, dynamic>> exportAll() {
    return transactions.map((tx) => tx.toMap()).toList();
  }
}
