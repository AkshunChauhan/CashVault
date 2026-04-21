import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/lock_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() {
    super.initState();
    // Prompt for auth automatically after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptAuth();
    });
  }

  Future<void> _promptAuth() async {
    await context.read<LockService>().authenticate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'App Locked',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock to access CashVault',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _promptAuth,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
