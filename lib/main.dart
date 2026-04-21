import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'models/debt_model.dart';
import 'models/transaction_model.dart';
import 'services/auth_service.dart';
import 'services/debt_service.dart';
import 'services/lock_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/transaction_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(DebtModelAdapter());

  // Initialize secure storage and get encryption key
  final storageService = StorageService();
  final encryptionKey = await storageService.getEncryptionKey();

  // Open encrypted Hive boxes
  await Hive.openBox<TransactionModel>(
    'transactions',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  await Hive.openBox<DebtModel>(
    'debts',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  await Hive.openBox(
    'settings',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  // Initialize services
  final transactionService = TransactionService();
  final authService = AuthService();
  final lockService = LockService();
  final debtService = DebtService(notificationService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: transactionService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: lockService),
        ChangeNotifierProvider.value(value: debtService),
      ],
      child: const CashVaultApp(),
    ),
  );
}
