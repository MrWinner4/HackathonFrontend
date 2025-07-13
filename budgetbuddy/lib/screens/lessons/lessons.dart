import 'package:budgetbuddy/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../colorscheme.dart';
import '../../widgets/content/page_viewer.dart';
import 'dart:math' as math;
import '../../services/api_service.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({Key? key}) : super(key: key);

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: backendBaseUrl,
  ));
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _testBackendConnection();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
    });

    try {      // Using a test endpoint for now
      final response = await _dio.get('/posts');
      if (response.statusCode == 200) {
        // Convert test data to lesson format
        final testData = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _lessons = testData.take(5).map((post) => {
            'title': post['title'],
            'subtitle': post['body'].substring(0, 50) + '...',
            'emoji': '📚',
            'pages': [
              {
                'title': post['title'],
                'content': post['body'],
                'type': 'text'
              }
            ]
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading lessons: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndViewContent(String topic) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print("generate");
      // Using a test endpoint for now
      final response = await _dio.post(
        '/posts',
        data: {'title': 'Generated: $topic', 'body': 'This is a test lesson about $topic', 'userId': 1},
      );
      if (response.statusCode == 201) {
        final lessonData = response.data;
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageViewer(
                pages: [
                  {
                    'title': lessonData['title'],
                    'content': lessonData['body'],
                    'type': 'text'
                  }
                ],
                title: lessonData['title'],
                emoji: '📚',
                contentType: 'lesson',
              ),
            ),
          );
        }
        // Reload lessons after generating new one
        _loadLessons();
      }
    } catch (e) {
      // Show error or fallback to sample data
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _viewLesson(Map<String, dynamic> lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageViewer(
          pages: List<Map<String, dynamic>>.from(lesson['pages']),
          title: lesson['title'],
          emoji: lesson['emoji'],
          contentType: 'lesson',
        ),
      ),
    );
  }

  Future<void> _testBackendConnection() async {
  }

  @override
  Widget build(BuildContext context) {
    // Removed hardcoded lessons list
    // Only use real, dynamic content here
    // Example progress data
    final double overallProgress = 0.6;
    final List<_CategoryProgress> categories = [
      _CategoryProgress('Saving', 0.8, AppColorScheme.accent),
      _CategoryProgress('Budgeting', 0.5, AppColorScheme.primaryVariant),
      _CategoryProgress('Spending', 0.3, AppColorScheme.secondaryVariant),
    ];

    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: Stack(
        children: [
          SafeArea(
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
              child: _lessons.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: AppColorScheme.secondaryVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lessons available yet',
                          style: TextStyle(
                            color: AppColorScheme.secondaryVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to generate your first lesson!',
                          style: TextStyle(
                            color: AppColorScheme.secondaryVariant.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _generateAndViewContent('budgeting basics'),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate First Lesson'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorScheme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: _lessons.length,
                    itemBuilder: (context, i) {
                      final lesson = _lessons[i];
                      return _LessonCard(
                        emoji: lesson['emoji'],
                        title: lesson['title'],
                        subtitle: lesson['subtitle'],
                        onTap: () => _viewLesson(lesson),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColorScheme.accent),
                ),
              ),
            ),
        ],
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
  final VoidCallback? onTap;
  const _LessonCard({
    required this.emoji, 
    required this.title, 
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
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

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
}
