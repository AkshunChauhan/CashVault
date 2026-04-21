import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'services/lock_service.dart';
import 'theme/app_theme.dart';

/// Root application widget.
class CashVaultApp extends StatelessWidget {
  const CashVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Consumer<LockService>(
        builder: (context, lockService, _) {
          if (lockService.isLocked) {
            return const LockScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}
