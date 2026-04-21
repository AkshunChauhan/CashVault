import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

/// Types of cash transactions.
enum TransactionType {
  add,
  expense,
}

/// Core data model for a cash transaction.
@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String type; // "add" or "expense"

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final Map<int, int> denominations;

  @HiveField(7)
  final double otherAmount;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.createdAt,
    this.denominations = const {},
    this.otherAmount = 0.0,
  });

  /// Whether this is an income transaction.
  bool get isIncome => type == 'add';

  /// Signed amount: positive for income, negative for expense.
  double get signedAmount => isIncome ? amount : -amount;

  /// Converts to a map for potential Firestore sync.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'denominations': denominations.map((k, v) => MapEntry(k.toString(), v)),
      'otherAmount': otherAmount,
    };
  }

  /// Creates a TransactionModel from a map (for Firestore sync).
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      denominations: (map['denominations'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},
      otherAmount: (map['otherAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
