import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colorscheme.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/episode_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/user_provider.dart';
import '../content/content_demo.dart';
import '../lessons/lessons.dart';
import '../chatbot/chatbot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.onViewProgress, this.onNavigateToLessons, this.onNavigateToChat}) : super(key: key);

  final VoidCallback? onViewProgress;
  final VoidCallback? onNavigateToLessons;
  final VoidCallback? onNavigateToChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    // Fetch user data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUserData();
    });
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
    final padding = screenWidth * 0.05; // 5% of screen width for padding

    void _showAddGoalSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const _AddGoalSheet(),
      );
    }

    return Scaffold(
      backgroundColor: AppColorScheme.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColorScheme.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {},
        child: Icon(Icons.add, size: screenWidth * 0.07), // Responsive icon size
        tooltip: 'Add Transaction',
      ),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh all providers
            await context.read<LessonProvider>().refreshLessons();
            await context.read<EpisodeProvider>().refreshEpisodes();
            await context.read<ProgressProvider>().initialize();
            await context.read<UserProvider>().fetchUserData();
          },
          color: AppColorScheme.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Modern Hero Section with Glassmorphism
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColorScheme.accent.withOpacity(0.12),
                            AppColorScheme.primaryVariant.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(screenWidth * 0.07),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorScheme.accent.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(screenWidth * 0.07),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: screenWidth * 0.06,
                                    color: AppColorScheme.secondary,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                                                              Text(
                                          'Welcome back,',
                                          style: TextStyle(
                                            color: AppColorScheme.secondaryVariant,
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Consumer<UserProvider>(
                                          builder: (context, userProvider, child) {
                                            return Text(
                                              userProvider.username,
                                              style: TextStyle(
                                                color: AppColorScheme.secondary,
                                                fontSize: screenWidth * 0.06,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                                                  Container(
                                    padding: EdgeInsets.all(screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      color: AppColorScheme.primaryVariant,
                                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      size: screenWidth * 0.05,
                                      color: AppColorScheme.secondary,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                                                          Container(
                                padding: EdgeInsets.all(screenWidth * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Balance',
                                          style: TextStyle(
                                            color: AppColorScheme.secondaryVariant,
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Consumer<UserProvider>(
                                          builder: (context, userProvider, child) {
                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                TweenAnimationBuilder<double>(
                                                  tween: Tween<double>(begin: 0, end: userProvider.balance),
                                                  duration: const Duration(seconds: 1),
                                                  builder: (context, value, child) => Text(
                                                    '\$${value.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color: AppColorScheme.accent,
                                                      fontSize: screenWidth * 0.07,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: -1,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Add/Subtract buttons
                                                _BalanceActionButton(
                                                  icon: Icons.add,
                                                  color: Colors.green,
                                                  onPressed: () async {
                                                    final amount = await _showAmountDialog(context, 'Add to Savings');
                                                    if (amount != null && amount > 0) {
                                                      final userProvider = context.read<UserProvider>();
                                                      userProvider.updateLocalBalance(userProvider.balance + amount);
                                                      userProvider.updateBalance(userProvider.balance);
                                                    }
                                                  },
                                                ),
                                                const SizedBox(width: 4),
                                                _BalanceActionButton(
                                                  icon: Icons.remove,
                                                  color: Colors.red,
                                                  onPressed: () async {
                                                    final amount = await _showAmountDialog(context, 'Subtract from Savings');
                                                    if (amount != null && amount > 0) {
                                                      final userProvider = context.read<UserProvider>();
                                                      userProvider.updateLocalBalance(userProvider.balance - amount);
                                                      userProvider.updateBalance(userProvider.balance);
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: AppColorScheme.accent,
                                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                    ),
                                    child: Icon(
                                      Icons.trending_up_rounded,
                                      color: Colors.white,
                                      size: screenWidth * 0.05,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // AI Chat Feature Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: padding),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (widget.onNavigateToChat != null) {
                            widget.onNavigateToChat!();
                          }
                        },
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorScheme.accent.withOpacity(0.1),
                                AppColorScheme.accent.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                            border: Border.all(
                              color: AppColorScheme.accent.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColorScheme.accent,
                                      AppColorScheme.accent.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColorScheme.accent.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.smart_toy_rounded,
                                  color: Colors.white,
                                  size: screenWidth * 0.06,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Financial Assistant',
                                      style: TextStyle(
                                        color: AppColorScheme.onPrimary,
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      'Get personalized financial advice and answers to your questions',
                                      style: TextStyle(
                                        color: AppColorScheme.secondaryVariant,
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColorScheme.accent,
                                size: screenWidth * 0.04,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Goals Section with Modern Cards
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Goals',
                              style: TextStyle(
                                color: AppColorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddGoalSheet(context),
                              icon: Icon(Icons.add_rounded, size: screenWidth * 0.045),
                              label: Text(
                                'Add Goal',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColorScheme.accent,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            if (userProvider.isLoading) {
                              return SizedBox(
                                height: screenHeight * 0.22,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColorScheme.accent,
                                  ),
                                ),
                              );
                            }
                            
                            if (userProvider.goals.isEmpty) {
                              return SizedBox(
                                height: screenHeight * 0.22,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: screenWidth * 0.08,
                                        color: AppColorScheme.secondaryVariant,
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Text(
                                        'No goals yet',
                                        style: TextStyle(
                                          color: AppColorScheme.secondaryVariant,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(
                                        'Add your first goal to get started!',
                                        style: TextStyle(
                                          color: AppColorScheme.secondaryVariant,
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            return SizedBox(
                              height: screenHeight * 0.22,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: userProvider.goals.length,
                                separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.04),
                                itemBuilder: (context, i) {
                                  final goal = userProvider.goals[i];
                                  return _ModernGoalCard(
                                    name: goal.name,
                                    progress: null, // will be calculated in the card
                                    price: goal.targetAmount,
                                    emoji: goal.emoji,
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                    allGoals: userProvider.goals,
                                    userBalance: userProvider.balance,
                                    goalIndex: i,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Featured Content Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Consumer2<LessonProvider, EpisodeProvider>(
                    builder: (context, lessonProvider, episodeProvider, child) {
                      final featuredLessons = lessonProvider.lessons.take(3).toList();
                      final featuredEpisodes = episodeProvider.episodes.take(2).toList();
                      
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Featured Content',
                                  style: TextStyle(
                                    color: AppColorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LessonsScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: AppColorScheme.accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            
                            // Featured Lessons
                            if (featuredLessons.isNotEmpty) ...[
                              Text(
                                'Popular Lessons',
                                style: TextStyle(
                                  color: AppColorScheme.secondaryVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              SizedBox(
                                height: screenHeight * 0.20,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featuredLessons.length,
                                  separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.04),
                                  itemBuilder: (context, index) {
                                    final lesson = featuredLessons[index];
                                    return _ContentCard(
                                      title: lesson['title'] ?? 'Untitled',
                                      subtitle: lesson['subtitle'] ?? 'Learn something new',
                                      emoji: lesson['emoji'] ?? '📚',
                                      type: 'lesson',
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      onTap: () {
                                        if (widget.onNavigateToLessons != null) {
                                          widget.onNavigateToLessons!();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                            
                            // Featured Episodes
                            if (featuredEpisodes.isNotEmpty) ...[
                              Text(
                                'Interactive Stories',
                                style: TextStyle(
                                  color: AppColorScheme.secondaryVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              SizedBox(
                                height: screenHeight * 0.20,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featuredEpisodes.length,
                                  separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.04),
                                  itemBuilder: (context, index) {
                                    final episode = featuredEpisodes[index];
                                    return _ContentCard(
                                      title: episode['title'] ?? 'Untitled',
                                      subtitle: episode['subtitle'] ?? 'Interactive story',
                                      emoji: episode['emoji'] ?? '📺',
                                      type: 'episode',
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      onTap: () {
                                        if (widget.onNavigateToLessons != null) {
                                          widget.onNavigateToLessons!();
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Quick Actions Grid
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            color: AppColorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: screenWidth * 0.04,
                          mainAxisSpacing: screenWidth * 0.04,
                          childAspectRatio: 1.15,
                          children: [
                            _QuickActionCard(
                              title: 'AI Chat',
                              subtitle: 'Get financial advice',
                              icon: Icons.smart_toy_rounded,
                              color: AppColorScheme.accent,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              onTap: () {
                                if (widget.onNavigateToChat != null) {
                                  widget.onNavigateToChat!();
                                }
                              },
                            ),
                            _QuickActionCard(
                              title: 'Learn',
                              subtitle: 'Explore lessons & stories',
                              icon: Icons.school_rounded,
                              color: AppColorScheme.accent,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              onTap: () {
                                if (widget.onNavigateToLessons != null) {
                                  widget.onNavigateToLessons!();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<double?> _showAmountDialog(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:  MaterialStateProperty.all(AppColorScheme.accentVariant),
              ),
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _ModernGoalCard extends StatelessWidget {
  final String name;
  final double? progress; // now optional, calculated inside
  final double price;
  final String emoji;
  final double screenWidth;
  final double screenHeight;
  final List<Goal> allGoals;
  final double userBalance;
  final int goalIndex;

  const _ModernGoalCard({
    required this.name,
    required this.progress,
    required this.price,
    required this.emoji,
    required this.screenWidth,
    required this.screenHeight,
    required this.allGoals,
    required this.userBalance,
    required this.goalIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate currentAmount for this goal based on balance allocation
    double remaining = userBalance;
    double currentAmount = 0;
    for (int i = 0; i <= goalIndex; i++) {
      final target = allGoals[i].targetAmount;
      if (i == goalIndex) {
        currentAmount = remaining >= target ? target : (remaining > 0 ? remaining : 0);
      }
      remaining -= target;
    }
    final double computedProgress = price > 0 ? (currentAmount / price).clamp(0.0, 1.0) : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Amount: \$${price.toStringAsFixed(2)}'),
                  Text('Progress: ${(computedProgress * 100).toStringAsFixed(1)}%'),
                  Text('Allocated: \$${currentAmount.toStringAsFixed(2)}'),
                  Text('Emoji: $emoji'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColorScheme.accent),
                  ),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: screenWidth * 0.35,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: screenWidth * 0.06),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorScheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                    child: Text(
                      '${(computedProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: AppColorScheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      child: CircularProgressIndicator(
                        value: computedProgress,
                        strokeWidth: 6,
                        backgroundColor: AppColorScheme.accent.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColorScheme.accent),
                      ),
                    ),
                    Text(
                      emoji,
                      style: TextStyle(fontSize: screenWidth * 0.05),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColorScheme.onPrimary,
                  fontSize: screenWidth * 0.035,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                '\$${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColorScheme.secondaryVariant,
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final String type;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const _ContentCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.type,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEpisode = type == 'episode';
    final accentColor = isEpisode ? AppColorScheme.primary : AppColorScheme.accent;
    
    return Container(
      width: screenWidth * 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.025),
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.015,
                        vertical: screenHeight * 0.003,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(screenWidth * 0.015),
                      ),
                      child: Text(
                        isEpisode ? 'Episode' : 'Lesson',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColorScheme.secondaryVariant,
                    fontSize: screenWidth * 0.03,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: screenWidth * 0.06,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                title,
                style: TextStyle(
                  color: AppColorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColorScheme.secondaryVariant,
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _BalanceActionButton({required this.icon, required this.color, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: color.withOpacity(0.15),
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: color, size: 18),
          onPressed: onPressed,
          splashRadius: 20,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// Keep the existing _AddGoalSheet class as is
class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet({Key? key}) : super(key: key);

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _emoji = '🎯';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final amount = double.parse(_amountController.text);
        
        await userProvider.addGoal(
          _nameController.text.trim(),
          amount,
          null, // No due date for now
        );
        
        Navigator.of(context).pop();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding goal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: mq.viewInsets,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.09)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.08,
            screenHeight * 0.03,
            screenWidth * 0.08,
            screenHeight * 0.03,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.12,
                  height: screenHeight * 0.006,
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Text(
                  'Add a New Goal',
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    color: AppColorScheme.secondary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () async {
                    // Show emoji picker (simple for now)
                    final emojis = ['🎯', '🚲', '🏖️', '💻', '🎸', '🏆', '📚', '🎮', '🏠', '🚗'];
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.06)),
                      ),
                      builder: (context) => GridView.count(
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        children: emojis.map((e) => InkWell(
                          onTap: () => Navigator.of(context).pop(e),
                          child: Center(child: Text(e, style: TextStyle(fontSize: screenWidth * 0.07))),
                        )).toList(),
                      ),
                    );
                    if (selected != null) setState(() => _emoji = selected);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColorScheme.accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.045),
                    child: Text(_emoji, style: TextStyle(fontSize: screenWidth * 0.09)),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: AppColorScheme.accent,
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    prefixIcon: Icon(Icons.flag_outlined, size: screenWidth * 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter a goal name' : null,
                ),
                SizedBox(height: screenHeight * 0.015),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  cursorColor: AppColorScheme.accent,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    prefixIcon: Icon(Icons.attach_money_rounded, size: screenWidth * 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter an amount';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.025),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: screenWidth * 0.06,
                            height: screenWidth * 0.06,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Add Goal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
