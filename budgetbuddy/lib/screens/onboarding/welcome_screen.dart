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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;
    
    // Responsive sizing
    final horizontalPadding = isTablet ? 48.0 : 24.0;
    final logoSize = isTablet ? 160.0 : (isSmallScreen ? 80.0 : 120.0);
    final iconSize = isTablet ? 80.0 : (isSmallScreen ? 40.0 : 60.0);
    final titleFontSize = isTablet ? 48.0 : (isSmallScreen ? 28.0 : 36.0);
    final taglineFontSize = isTablet ? 22.0 : (isSmallScreen ? 16.0 : 18.0);
    final buttonHeight = isTablet ? 64.0 : (isSmallScreen ? 48.0 : 56.0);
    final featureIconSize = isTablet ? 56.0 : (isSmallScreen ? 40.0 : 48.0);
    final featureIconInnerSize = isTablet ? 28.0 : (isSmallScreen ? 20.0 : 24.0);

    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  // Top section with logo and tagline
                  SizedBox(
                    height: screenHeight * (isSmallScreen ? 0.25 : 0.35),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo/Icon
                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: AppColorScheme.accent,
                              borderRadius: BorderRadius.circular(logoSize * 0.25),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorScheme.accent.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: iconSize,
                              color: AppColorScheme.onAccent,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 32),
                          
                          // App Name
                          Text(
                            'Budget Buddy',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColorScheme.secondary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 16),
                          
                          // Tagline
                          Text(
                            'Entertainment that moves you forward.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: taglineFontSize,
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
                  SizedBox(
                    height: screenHeight * (isSmallScreen ? 0.37 : 0.27),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFeatureItem(
                            icon: Icons.trending_up_rounded,
                            title: 'Budget Tracker',
                            subtitle: 'Insightful budget tracker to help you hit your goals',
                            iconSize: featureIconSize,
                            innerIconSize: featureIconInnerSize,
                            isTablet: isTablet,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 18),
                          _buildFeatureItem(
                            icon: Icons.psychology_rounded,
                            title: 'Entertaining Education',
                            subtitle: 'Learn the essentials of finance through short stories',
                            iconSize: featureIconSize,
                            innerIconSize: featureIconInnerSize,
                            isTablet: isTablet,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 18),
                          _buildFeatureItem(
                            icon: Icons.chat_bubble_outline,
                            title: 'Personal Tutor',
                            subtitle: 'AI Chatbot catered to your questions and needs',
                            iconSize: featureIconSize,
                            innerIconSize: featureIconInnerSize,
                            isTablet: isTablet,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom section with buttons
                  SizedBox(
                    height: screenHeight * (isSmallScreen ? 0.25 : 0.3),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Get Started Button
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
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
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : (isSmallScreen ? 16 : 18),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          
                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
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
                              child: Text(
                                'I already have an account',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          
                          // Terms and Privacy
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    'By continuing, you agree to our ',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: AppColorScheme.secondaryVariant,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to terms
                                  },
                                  child: Text(
                                    'Terms',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: AppColorScheme.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    ' and ',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: AppColorScheme.secondaryVariant,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to privacy
                                  },
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: AppColorScheme.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double iconSize,
    required double innerIconSize,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColorScheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(iconSize * 0.25),
          ),
          child: Icon(
            icon,
            color: AppColorScheme.accent,
            size: innerIconSize,
          ),
        ),
        SizedBox(width: isTablet ? 20 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
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
