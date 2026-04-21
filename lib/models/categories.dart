/// Predefined categories for transactions.
class Categories {
  Categories._();

  static const List<String> income = [
    'Salary',
    'Freelance',
    'Gift',
    'Refund',
    'Other Income',
  ];

  static const List<String> expense = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Rent',
    'Health',
    'Entertainment',
    'Education',
    'Other',
  ];

  /// Returns categories based on transaction type.
  static List<String> forType(String type) {
    return type == 'add' ? income : expense;
  }

  /// All categories combined.
  static List<String> get all => [...income, ...expense];
}
