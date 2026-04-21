import 'package:hive/hive.dart';

part 'debt_model.g.dart';

@HiveType(typeId: 1)
class DebtModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type; // 'lend' (they owe me) or 'borrow' (i owe them)

  @HiveField(4)
  final DateTime? dueDate;

  @HiveField(5)
  final bool isSettled;

  @HiveField(6)
  final DateTime createdAt;

  DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    this.dueDate,
    this.isSettled = false,
    required this.createdAt,
  });

  bool get isLent => type == 'lend';

  DebtModel copyWith({
    String? personName,
    double? amount,
    String? type,
    DateTime? dueDate,
    bool? isSettled,
  }) {
    return DebtModel(
      id: id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt,
    );
  }
}
