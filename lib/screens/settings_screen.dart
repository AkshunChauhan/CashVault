import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

/// Settings screen with auth toggle and future-ready options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AuthService>(
        builder: (context, auth, _) {
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
                icon: Icons.sync_outlined,
                title: 'Cloud Sync',
                subtitle: 'Coming soon',
                trailing: Switch(
                  value: false,
                  onChanged: null, // Disabled - future feature
                ),
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
                subtitle: 'PIN or biometric • Coming soon',
                trailing: Switch(
                  value: false,
                  onChanged: null, // Disabled - future feature
                ),
              ),

              const Divider(indent: 16, endIndent: 16),

              // ── About Section ────────────────────────────────
              _SectionHeader(title: 'About'),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'CashVault',
                subtitle: 'Version 1.0.0',
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'Your data never leaves your device',
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'Built with privacy in mind',
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
