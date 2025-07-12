import 'package:flutter/material.dart';
import '../../colorscheme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example user data
    final String userName = 'Alex Johnson';
    final String userEmail = 'alex.johnson@email.com';
    final String appVersion = '1.0.0';

    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColorScheme.accent.withOpacity(0.15),
                  child: const Icon(Icons.person_rounded, size: 40, color: AppColorScheme.accent),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColorScheme.secondaryVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Profile actions card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _ProfileActionTile(
                    icon: Icons.edit_rounded,
                    label: 'Edit Profile',
                    onTap: () {},
                  ),
                  _ProfileActionTile(
                    icon: Icons.lock_rounded,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                  _ProfileActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Log Out',
                    onTap: () {},
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // App info card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColorScheme.secondaryVariant),
                  const SizedBox(width: 14),
                  const Text(
                    'App Version',
                    style: TextStyle(
                      color: AppColorScheme.secondaryVariant,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    appVersion,
                    style: const TextStyle(
                      color: AppColorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColorScheme.accent),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppColorScheme.secondary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFFB0B0B0)),
    );
  }
}
