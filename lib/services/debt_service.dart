import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/debt_model.dart';
import 'notification_service.dart';

class DebtService extends ChangeNotifier {
  static const _boxName = 'debts';
  final NotificationService _notificationService;

  DebtService(this._notificationService);

  Box<DebtModel> get _box => Hive.box<DebtModel>(_boxName);

  List<DebtModel> get activeDebts =>
      _box.values.where((d) => !d.isSettled).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<DebtModel> get settledDebts =>
      _box.values.where((d) => d.isSettled).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double get totalOwedToMe {
    return activeDebts
        .where((d) => d.isLent)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIOwe {
    return activeDebts
        .where((d) => !d.isLent)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> addDebt({
    required String personName,
    required double amount,
    required String type,
    DateTime? dueDate,
  }) async {
    final debt = DebtModel(
      id: const Uuid().v4(),
      personName: personName,
      amount: amount,
      type: type,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    await _box.put(debt.id, debt);

    if (dueDate != null) {
      // Schedule reminder for 9 AM on the due date
      final reminderTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        9,
        0,
      );
      
      if (reminderTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleReminder(
          id: debt.id.hashCode,
          title: type == 'lend' ? 'Payment Due' : 'Debt Repayment',
          body: type == 'lend'
              ? '$personName owes you \$${amount.toStringAsFixed(2)} today.'
              : 'You owe $personName \$${amount.toStringAsFixed(2)} today.',
          scheduledDate: reminderTime,
        );
      }
    }

    notifyListeners();
  }

  Future<void> markSettled(String id) async {
    final debt = _box.get(id);
    if (debt != null) {
      final updated = debt.copyWith(isSettled: true);
      await _box.put(id, updated);
      
      // Cancel any pending notification
      await _notificationService.cancelReminder(id.hashCode);
      
      notifyListeners();
    }
  }

  Future<void> deleteDebt(String id) async {
    await _box.delete(id);
    await _notificationService.cancelReminder(id.hashCode);
    notifyListeners();
  }
}
