import 'package:flutter/material.dart';
import '../../colorscheme.dart';
import 'dart:math' as math;

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> lessons = [
      {
        'emoji': '💡',
        'title': 'Saving Basics',
        'subtitle': 'Start your journey'
      },
      {
        'emoji': '📊',
        'title': 'Budgeting 101',
        'subtitle': 'Master your money'
      },
      {
        'emoji': '🛒',
        'title': 'Smart Spending',
        'subtitle': 'Spend wisely'
      },
      {
        'emoji': '🏦',
        'title': 'Banking Explained',
        'subtitle': 'How banks work for you'
      },
      {
        'emoji': '💳',
        'title': 'Credit Cards',
        'subtitle': 'Using credit responsibly'
      },
    ];

    // Example progress data
    final double overallProgress = 0.6;
    final List<_CategoryProgress> categories = [
      _CategoryProgress('Saving', 0.8, AppColorScheme.accent),
      _CategoryProgress('Budgeting', 0.5, AppColorScheme.primaryVariant),
      _CategoryProgress('Spending', 0.3, AppColorScheme.secondaryVariant),
    ];

    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress tracker section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColorScheme.accent.withOpacity(0.15),
                    child: const Icon(Icons.menu_book_rounded, size: 32, color: AppColorScheme.accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Lessons',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Learn about money, one lesson at a time.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColorScheme.secondaryVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    // Circular progress
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: overallProgress,
                            strokeWidth: 7,
                            backgroundColor: AppColorScheme.primaryVariant.withOpacity(0.18),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColorScheme.accent),
                          ),
                          Text('${(overallProgress * 100).toInt()}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Bar chart for categories
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...categories.map((cat) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        cat.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColorScheme.secondaryVariant,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: cat.color.withOpacity(0.13),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(
                                            widthFactor: cat.progress,
                                            child: Container(
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: cat.color,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${(cat.progress * 100).toInt()}%',
                                        style: const TextStyle(fontSize: 12, color: AppColorScheme.secondaryVariant)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Lessons list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: lessons.length,
                itemBuilder: (context, i) {
                  final lesson = lessons[i];
                  return _LessonCard(
                    emoji: lesson['emoji']!,
                    title: lesson['title']!,
                    subtitle: lesson['subtitle']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProgress {
  final String label;
  final double progress;
  final Color color;
  _CategoryProgress(this.label, this.progress, this.color);
}

class _LessonCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const _LessonCard({required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
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
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFFB0B0B0)),
        ],
      ),
    );
  }
}
