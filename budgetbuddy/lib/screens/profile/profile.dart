import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../colorscheme.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Fetch user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUserData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return const Center(child: LoadingWidget());
            }
            
            if (userProvider.error != null) {
              return Center(
                child: CustomErrorWidget(
                  message: userProvider.error!,
                  onRetry: () => userProvider.fetchUserData(),
                ),
              );
            }

            final user = FirebaseAuth.instance.currentUser;
            final userData = userProvider.userData;
            
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  children: [
                    _buildHeader(user, userData),
                    const SizedBox(height: 32),
                    _buildStatsCard(userData),
                    const SizedBox(height: 24),
                    _buildProfileActionsCard(),
                    const SizedBox(height: 24),
                    _buildSettingsCard(userData),
                    const SizedBox(height: 24),
                    _buildAppInfoCard(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(User? user, UserData? userData) {
    final displayName = userData?.username ?? user?.displayName ?? 'User';
    final email = user?.email ?? 'No email';
    final photoURL = user?.photoURL;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorScheme.accent.withOpacity(0.1),
            AppColorScheme.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColorScheme.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColorScheme.accent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorScheme.accent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColorScheme.accent.withOpacity(0.15),
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 44,
                      color: AppColorScheme.accent,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColorScheme.secondaryVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColorScheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Budget Buddy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColorScheme.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditProfileDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorScheme.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(UserData? userData) {
    final balance = userData?.balance ?? 0.0;
    final goals = userData?.goals ?? [];
    final completedGoals = goals.where((goal) => goal.progress >= 1.0).length;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColorScheme.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Current Balance',
                  value: '\$${balance.toStringAsFixed(2)}',
                  color: AppColorScheme.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.flag_rounded,
                  label: 'Active Goals',
                  value: '${goals.length}',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  value: '$completedGoals',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Success Rate',
                  value: goals.isEmpty ? '0%' : '${((completedGoals / goals.length) * 100).round()}%',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColorScheme.secondaryVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileActionTile(
            icon: Icons.person_rounded,
            label: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => _showEditProfileDialog(context),
          ),
          _ProfileActionTile(
            icon: Icons.lock_rounded,
            label: 'Change Password',
            subtitle: 'Update your account security',
            onTap: () => _showChangePasswordDialog(context),
          ),
          _ProfileActionTile(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: () => _showNotificationsDialog(context),
          ),
          _ProfileActionTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(UserData? userData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_rounded,
            label: 'Push Notifications',
            value: userData?.notificationsEnabled ?? true,
            onChanged: (value) => _updateNotificationSettings(value),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            label: 'Dark Mode',
            value: userData?.darkMode ?? false,
            onChanged: (value) => _updateDarkModeSettings(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.info_outline_rounded,
            label: 'App Version',
            value: '1.0.0',
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            value: 'Contact us',
            onTap: () => _showHelpDialog(context),
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.privacy_tip_rounded,
            label: 'Privacy Policy',
            value: 'Read more',
            onTap: () => _showPrivacyDialog(context),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showEditProfileDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userData = context.read<UserProvider>().userData;
    
    final nameController = TextEditingController(text: userData?.username ?? user?.displayName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              enabled: false, // Email editing requires re-authentication
            ),
          ],
        ),
                 actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(),
             child: const Text('Cancel'),
           ),
           ElevatedButton(
             onPressed: () async {
               try {
                 await user?.updateDisplayName(nameController.text);
                 Navigator.of(context).pop();
                 _showSuccessSnackBar('Profile updated successfully!');
               } catch (e) {
                 _showErrorSnackBar('Failed to update profile: $e');
               }
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColorScheme.accent,
               foregroundColor: Colors.white,
             ),
             child: const Text('Save'),
           ),
         ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
                 actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(),
             child: const Text('Cancel'),
           ),
           ElevatedButton(
             onPressed: () async {
               if (newPasswordController.text != confirmPasswordController.text) {
                 _showErrorSnackBar('New passwords do not match');
                 return;
               }
               
               try {
                 final user = FirebaseAuth.instance.currentUser;
                 final credential = EmailAuthProvider.credential(
                   email: user?.email ?? '',
                   password: currentPasswordController.text,
                 );
                 
                 await user?.reauthenticateWithCredential(credential);
                 await user?.updatePassword(newPasswordController.text);
                 
                 Navigator.of(context).pop();
                 _showSuccessSnackBar('Password changed successfully!');
               } catch (e) {
                 _showErrorSnackBar('Failed to change password: $e');
               }
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColorScheme.accent,
               foregroundColor: Colors.white,
             ),
             child: const Text('Change'),
           ),
         ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('Notification settings will be implemented in the next version.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await FirebaseAuth.instance.signOut();
                _showSuccessSnackBar('Logged out successfully!');
              } catch (e) {
                _showErrorSnackBar('Error logging out: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('For support, please contact us at support@budgetbuddy.com'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Our privacy policy can be found at budgetbuddy.com/privacy'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateNotificationSettings(bool value) {
    // This would typically update the backend
    _showSuccessSnackBar('Notification settings updated!');
  }

  void _updateDarkModeSettings(bool value) {
    // This would typically update the backend
    _showSuccessSnackBar('Theme settings updated!');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColorScheme.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withOpacity(0.1)
              : AppColorScheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColorScheme.accent,
          size: 24,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppColorScheme.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColorScheme.secondaryVariant,
          fontSize: 13,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isDestructive ? Colors.red : AppColorScheme.secondaryVariant,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColorScheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColorScheme.accent,
          size: 24,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColorScheme.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColorScheme.accent,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColorScheme.secondaryVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColorScheme.secondaryVariant,
          size: 24,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColorScheme.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: onTap != null
          ? Text(
              value,
              style: const TextStyle(
                color: AppColorScheme.accent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )
          : Text(
              value,
              style: const TextStyle(
                color: AppColorScheme.secondaryVariant,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
