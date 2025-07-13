import 'package:flutter/material.dart';
import '../../colorscheme.dart';
import '../content/content_demo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String userName = 'Alex';
    final double balance = 1240.50;
    final List<Map<String, dynamic>> goals = [
      {'name': 'New Bike', 'progress': 0.7, 'price': 500.0},
      {'name': 'Vacation', 'progress': 0.4, 'price': 1200.0},
      {'name': 'Laptop', 'progress': 0.2, 'price': 900.0},
    ];
    final List<Map<String, String>> quickActions = [
      {'label': 'Add Goal', 'icon': 'add_circle_outline'},
      {'label': 'Edit Goals', 'icon': 'remove_circle_outline'},
    ];

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
        foregroundColor: AppColorScheme.onAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {},
        child: const Icon(Icons.add, size: 32),
        tooltip: 'Add Transaction',
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Top Section: Greeting & Balance
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColorScheme.accent.withOpacity(0.12),
                      AppColorScheme.primaryVariant.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorScheme.accent.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColorScheme.primaryVariant,
                          child: const Icon(Icons.person,
                              size: 32, color: AppColorScheme.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: AppColorScheme.secondaryVariant,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  color: AppColorScheme.secondary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Animated Balance
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: AppColorScheme.secondaryVariant,
                        fontSize: 15,
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: balance),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) => Text(
                        '\$${value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColorScheme.accent,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Goals Section: Horizontal Scroll with Progress Rings
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Goals',
                    style: TextStyle(
                      color: AppColorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: goals.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        if (i == goals.length) {
                          // Add extra space at the end to prevent overflow
                          return const SizedBox(width: 24);
                        }
                        final goal = goals[i];
                        return _GoalCard(
                          name: goal['name'],
                          progress: goal['progress'],
                          price: goal['price'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: quickActions.map((action) {
                  return _QuickActionPill(
                    label: action['label']!,
                    icon: action['icon']!,
                    onTap: () {
                      if (action['label'] == 'Add Goal') {
                        _showAddGoalSheet(context);
                      } else if (action['label'] == 'Content Demo') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContentDemoScreen(),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            // Lessons/Stories Carousel
            // (Removed demo/filler content)
            // Episodes Carousel
            // (Removed demo/filler content)
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String name;
  final double progress;
  final double price;
  const _GoalCard(
      {required this.name, required this.progress, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor:
                      AppColorScheme.primaryVariant.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColorScheme.accent),
                ),
              ),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColorScheme.secondary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColorScheme.secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${price.toStringAsFixed(0)}',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: AppColorScheme.secondaryVariant,
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;
  const _QuickActionPill(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColorScheme.primaryVariant,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(_iconFromString(icon), color: AppColorScheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'add_circle_outline':
        return Icons.add_circle_outline;
      case 'remove_circle_outline':
        return Icons.remove_circle_outline;
      case 'smart_toy_outlined':
        return Icons.smart_toy_outlined;
      default:
        return Icons.circle;
    }
  }
}

class _LessonCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const _LessonCard(
      {required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColorScheme.secondaryVariant,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      // Simulate a save, then pop
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: mq.viewInsets,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Text(
                  'Add a New Goal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    // Show emoji picker (simple for now)
                    final emojis = ['🎯', '🚲', '🏖️', '💻', '🎸', '🏆', '📚', '🎮', '🏠', '🚗'];
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => GridView.count(
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        children: emojis.map((e) => InkWell(
                          onTap: () => Navigator.of(context).pop(e),
                          child: Center(child: Text(e, style: const TextStyle(fontSize: 28))),
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
                    padding: const EdgeInsets.all(18),
                    child: Text(_emoji, style: const TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: AppColorScheme.accent,
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter a goal name' : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  cursorColor: AppColorScheme.accent,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
