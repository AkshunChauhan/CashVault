import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../services/lock_service.dart';
import '../services/transaction_service.dart';
import '../services/report_issue_service.dart';

/// Settings screen with auth toggle, CSV export, and security options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<AuthService, LockService>(
        builder: (context, auth, lock, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // ── Account Section ──────────────────────────────
              _SectionHeader(title: 'Account'),
              _SettingsTile(
                icon: Icons.account_circle_outlined,
                title: auth.isSignedIn
                    ? (auth.displayName ?? 'Signed In')
                    : 'Sign in with Google',
                subtitle: auth.isSignedIn
                    ? auth.userEmail
                    : 'Optional • Enables cloud backup',
                trailing: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : auth.isSignedIn
                        ? TextButton(
                            onPressed: () => _handleSignOut(context, auth),
                            child: const Text('Sign Out'),
                          )
                        : const Icon(Icons.chevron_right, size: 20),
                onTap: auth.isSignedIn
                    ? null
                    : () => _handleSignIn(context, auth),
              ),

              const Divider(indent: 16, endIndent: 16),

              // ── Data Section ─────────────────────────────────
              _SectionHeader(title: 'Data'),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Export Data',
                subtitle: 'Export transactions to CSV',
                onTap: () async {
                  final exportService = ExportService(context.read<TransactionService>());
                  await exportService.exportToCsv();
                },
              ),
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: 'Local Data',
                subtitle: 'All data is encrypted and stored on device',
                trailing: const Icon(Icons.check_circle_outline,
                    size: 20, color: Color(0xFF059669)),
              ),

              const Divider(indent: 16, endIndent: 16),

              // ── Security Section ─────────────────────────────
              _SectionHeader(title: 'Security'),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'App Lock',
                subtitle: 'Require PIN or biometric to open',
                trailing: Switch(
                  value: lock.isAppLockEnabled,
                  onChanged: (val) {
                    lock.toggleAppLock(val);
                  },
                ),
              ),

              const Divider(indent: 16, endIndent: 16),

              // ── About Section ────────────────────────────────
              _SectionHeader(title: 'About & Support'),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'App Info',
                subtitle: 'Version, Credits & Legal',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'CashVault',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Akshun Chauhan',
                    applicationIcon: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/logo.png', width: 48, height: 48),
                    ),
                    children: [
                      const SizedBox(height: 16),
                      const Text('Developer: Akshun Chauhan'),
                      const SizedBox(height: 8),
                      const Text('Support: Local Offline Documentation (README.md)'),
                      const SizedBox(height: 8),
                      const Text('Built with privacy as the absolute priority. Your data never leaves your device unless you explicitly enable cloud features.'),
                    ],
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Report an Issue',
                subtitle: 'Send feedback to the developer',
                onTap: () => _showReportIssueDialog(context, auth),
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy Focus',
                subtitle: 'Your data never leaves your device by default',
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'Crafted by Akshun Chauhan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context, AuthService auth) {
    final controller = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report Issue'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Explain the issue you are facing or suggest a feature. This will be sent directly to the developer.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Describe the issue...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (!auth.isSignedIn) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Note: You are not signed in. Reports will be sent anonymously.',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (controller.text.trim().isEmpty) return;
                          
                          setState(() => isSubmitting = true);
                          
                          // Calls our service
                          // Note: Once Firebase is configured, this links to the Firestore logic.
                          final service = ReportIssueService();
                          await service.submitIssueMock(
                            controller.text.trim(),
                            auth.userEmail ?? 'Anonymous',
                          );

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you! Issue recorded. (Requires Firebase setup to sync).'),
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _handleSignIn(BuildContext context, AuthService auth) async {
    final success = await auth.signInWithGoogle();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Signed in successfully'
                : 'Sign-in unavailable. Configure Firebase first.',
          ),
        ),
      );
    }
  }

  void _handleSignOut(BuildContext context, AuthService auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('You can still use the app offline.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await auth.signOut();
    }
  }
}

// ────────────────────────────────────────────────────────────────
// Reusable Settings Widgets
// ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, size: 22, color: theme.textTheme.bodyMedium?.color),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.labelSmall)
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
