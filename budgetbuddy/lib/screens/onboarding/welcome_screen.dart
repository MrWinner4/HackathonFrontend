import 'package:flutter/material.dart';
import '../../colorscheme.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top section with logo and tagline
              Expanded(
                flex: 3,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColorScheme.accent,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColorScheme.accent.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 60,
                          color: AppColorScheme.onAccent,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // App Name
                      const Text(
                        'EduFlow',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColorScheme.secondary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tagline
                      const Text(
                        'Entertainment that moves you forward.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColorScheme.secondaryVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Middle section with features
              Expanded(
                flex: 2,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.trending_up_rounded,
                        title: 'Personalized Learning',
                        subtitle: 'AI-powered content tailored to your goals',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                        icon: Icons.psychology_rounded,
                        title: 'Smart Skills',
                        subtitle: 'Master finance, productivity & wellness',
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                        icon: Icons.camera_alt_rounded,
                        title: 'Entertaining Stories',
                        subtitle: 'Learn essential life skills through engaging stories',
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom section with buttons
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to signup screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorScheme.accent,
                            foregroundColor: AppColorScheme.onAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate to sign in screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColorScheme.secondary,
                            side: const BorderSide(
                              color: AppColorScheme.secondary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'I already have an account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Terms and Privacy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'By continuing, you agree to our ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorScheme.secondaryVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to terms
                            },
                            child: Text(
                              'Terms',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColorScheme.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ' and ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColorScheme.secondaryVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to privacy
                            },
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColorScheme.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColorScheme.secondaryVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
