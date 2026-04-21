import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import 'transaction_service.dart';

class ExportService {
  final TransactionService _transactionService;

  ExportService(this._transactionService);

  Future<void> exportToCsv() async {
    final transactions = _transactionService.transactions;
    if (transactions.isEmpty) return;

    final buffer = StringBuffer();
    // Headers
    buffer.writeln('Date,Type,Category,Amount,Bills Summary,Note');

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final tx in transactions) {
      final date = dateFormat.format(tx.createdAt);
      final type = tx.isIncome ? 'Income' : 'Expense';
      final category = _escapeCsv(tx.category);
      final billsSummary = _escapeCsv(tx.denominations.entries
          .map((e) => '${e.value}x \$${e.key}')
          .join(', '));
      final note = _escapeCsv(tx.note ?? '');
      
      buffer.writeln('$date,$type,$category,${tx.amount},$billsSummary,$note');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/cashvault_export.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'CashVault Data Export',
    );
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
