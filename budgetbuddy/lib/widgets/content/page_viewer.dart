import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../colorscheme.dart';
import '../../providers/progress_provider.dart';

class PageViewer extends StatefulWidget {
  final List<Map<String, dynamic>> pages;
  final String title;
  final String emoji;
  final String contentType; // 'story' or 'lesson'

  const PageViewer({
    Key? key,
    required this.pages,
    required this.title,
    required this.emoji,
    required this.contentType,
  }) : super(key: key);

  @override
  State<PageViewer> createState() => _PageViewerState();
}

class _PageViewerState extends State<PageViewer> with TickerProviderStateMixin {
  int currentPageIndex = 0;
  List<String> userChoices = [];
  Map<String, dynamic> quizAnswers = {};
  
  late AnimationController _pageController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  
  // Scroll controller for header fade
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  
  // Track lesson start time
  DateTime? _lessonStartTime;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _pageController.forward();
    _progressController.forward();
    
    // Listen to scroll changes for header fade
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    
    // Track lesson start time
    _lessonStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _changePage(int newIndex) {
    _pageController.reverse().then((_) {
      setState(() {
        currentPageIndex = newIndex;
      });
      _pageController.forward();
      
      // Scroll to top when changing pages
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = widget.pages[currentPageIndex];
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLastPage = currentPageIndex == widget.pages.length - 1;
    
    // Calculate header opacity based on scroll
    final headerOpacity = (1.0 - (_scrollOffset / 100).clamp(0.0, 1.0)).clamp(0.0, 1.0);
    
    return WillPopScope(
      onWillPop: () async {
        // Allow back navigation only through the back button
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColorScheme.background,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Modern App Bar with Glassmorphism and fade effect
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: true, // Show back button
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedOpacity(
                  opacity: headerOpacity,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorScheme.primary.withOpacity(0.9),
                          AppColorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: AnimatedOpacity(
                opacity: headerOpacity,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColorScheme.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Progress Indicator
                AnimatedOpacity(
                  opacity: headerOpacity,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColorScheme.accent.withAlpha(50),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColorScheme.accentVariant.withAlpha(75),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return SizedBox(
                              width: 60,
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value * ((currentPageIndex + 1) / widget.pages.length),
                                backgroundColor: AppColorScheme.accentVariant.withAlpha(75),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColorScheme.accent),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${currentPageIndex + 1}/${widget.pages.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColorScheme.accentVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Page Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: EdgeInsets.all(isTablet ? 32 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Header with Modern Design
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorScheme.accent.withOpacity(0.1),
                                AppColorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColorScheme.accent.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page Title with Icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColorScheme.accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isLastPage ? Icons.celebration : Icons.auto_stories,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentPage['title'] ?? 'Untitled Page',
                                      style: TextStyle(
                                        fontSize: isTablet ? 28 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorScheme.onBackground,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Content Card with Glassmorphism
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
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
                              // Enhanced Markdown Content
                              MarkdownBody(
                                data: currentPage['content'] ?? '',
                                styleSheet: MarkdownStyleSheet(
                                  h1: TextStyle(
                                    fontSize: isTablet ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorScheme.onBackground,
                                    height: 1.3,
                                  ),
                                  h2: TextStyle(
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorScheme.onBackground,
                                    height: 1.3,
                                  ),
                                  h3: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorScheme.onBackground,
                                    height: 1.3,
                                  ),
                                  p: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    height: 1.6,
                                    color: AppColorScheme.secondary,
                                  ),
                                  strong: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorScheme.onBackground,
                                  ),
                                  em: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: AppColorScheme.accent,
                                  ),
                                  blockquote: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                    backgroundColor: AppColorScheme.accent.withOpacity(0.1),
                                  ),
                                  code: TextStyle(
                                    backgroundColor: Colors.grey[100],
                                    color: AppColorScheme.onBackground,
                                    fontFamily: 'monospace',
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                ),
                              ),
                              
                              // Interactive Elements
                              if (currentPage['interactive_elements'] != null) ...[
                                const SizedBox(height: 32),
                                ...currentPage['interactive_elements'].map<Widget>((element) => 
                                  _buildInteractiveElement(element, currentPage['id']),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Navigation Section
                        _buildNavigationSection(currentPage, isTablet, isLastPage),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveElement(Map<String, dynamic> element, String pageId) {
    switch (element['type']) {
      case 'quiz':
        return _buildQuizElement(element, pageId);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQuizElement(Map<String, dynamic> element, String pageId) {
    final question = element['question'];
    final options = List<String>.from(element['options']);
    final correctAnswer = element['correct'];
    
    // Create unique quiz identifier using pageId and question text
    final quizId = '${pageId}_${question.hashCode}';
    final userAnswer = quizAnswers[quizId];
    final isAnswered = userAnswer != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorScheme.primaryVariant.withOpacity(0.1),
            AppColorScheme.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColorScheme.primaryVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header with better visibility
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorScheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColorScheme.accent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorScheme.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorScheme.onBackground,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = userAnswer == index;
            final isCorrect = index == correctAnswer;
            
            Color backgroundColor = Colors.white;
            Color borderColor = Colors.grey.shade200;
            Color textColor = AppColorScheme.secondary;
            
            if (isAnswered) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
                textColor = Colors.green.shade700;
              } else if (isSelected) {
                backgroundColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red;
                textColor = Colors.red.shade700;
              }
            } else if (isSelected) {
              backgroundColor = AppColorScheme.accent.withOpacity(0.1);
              borderColor = AppColorScheme.accent;
              textColor = AppColorScheme.accent;
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isAnswered ? null : () => _answerQuiz(quizId, index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: borderColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAnswered && isCorrect 
                              ? Colors.green 
                              : isAnswered && isSelected 
                                ? Colors.red 
                                : isSelected 
                                  ? AppColorScheme.accent 
                                  : Colors.grey.shade300,
                          ),
                          child: Icon(
                            isAnswered && isCorrect 
                              ? Icons.check 
                              : isAnswered && isSelected 
                                ? Icons.close 
                                : isSelected 
                                  ? Icons.radio_button_checked 
                                  : Icons.radio_button_unchecked,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          
          // Feedback
          if (isAnswered) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: correctAnswer == userAnswer 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: correctAnswer == userAnswer 
                    ? Colors.green.withOpacity(0.3) 
                    : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    correctAnswer == userAnswer ? Icons.check_circle : Icons.info,
                    color: correctAnswer == userAnswer ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      correctAnswer == userAnswer 
                        ? 'Excellent! You got it right!' 
                        : 'Not quite right. The correct answer is: ${options[correctAnswer]}',
                      style: TextStyle(
                        color: correctAnswer == userAnswer ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationSection(Map<String, dynamic> currentPage, bool isTablet, bool isLastPage) {
    // For stories with choices
    if (currentPage['choices'] != null) {
      return Column(
        children: [
          ...currentPage['choices'].map<Widget>((choice) => 
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _makeChoice(choice),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorScheme.accent,
                          AppColorScheme.accent.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorScheme.accent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward,
                          color: AppColorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            choice['text'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ).toList(),
          
          // Add finish button for episodes on the last page
          if (isLastPage && widget.contentType == 'episode') ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await _completeLesson();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green,
                          Colors.green.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Finish Episode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }
    
    // For lessons with standard navigation
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Navigation buttons
          Row(
            children: [
              if (currentPageIndex > 0)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _changePage(currentPageIndex - 1),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Previous',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (currentPageIndex < widget.pages.length - 1) ...[
                if (currentPageIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _changePage(currentPageIndex + 1),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColorScheme.accent,
                              AppColorScheme.accent.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColorScheme.accent.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: AppColorScheme.onPrimary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Finish Lesson section for last page
          if (isLastPage) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.green.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.celebration,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.contentType == 'episode' ? 'Episode Complete!' : 'Lesson Complete!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                                     Text(
                     widget.contentType == 'episode' 
                       ? 'Congratulations! You\'ve successfully watched this episode. Keep exploring more interactive stories to enhance your financial knowledge.'
                       : 'Congratulations! You\'ve successfully completed this lesson. You can now apply what you\'ve learned to your financial journey.',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontSize: 16,
                       color: Colors.green.shade700,
                       height: 1.5,
                     ),
                   ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _completeLesson();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.home),
                      label: Text(widget.contentType == 'episode' ? 'Back to Episodes' : 'Back to Lessons'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _makeChoice(Map<String, dynamic> choice) {
    setState(() {
      userChoices.add(choice['text']);
      // Find the next page
      final nextPageId = choice['next_page'];
      final nextPageIndex = widget.pages.indexWhere((page) => page['id'] == nextPageId);
      if (nextPageIndex != -1) {
        _changePage(nextPageIndex);
      }
    });
  }

  void _answerQuiz(String quizId, int answer) {
    setState(() {
      quizAnswers[quizId] = answer;
    });
  }

  // Complete lesson/episode and track progress
  Future<void> _completeLesson() async {
    if (_lessonStartTime != null) {
      final timeSpent = DateTime.now().difference(_lessonStartTime!).inMinutes;
      
      // Calculate score based on quiz performance
      int score = 100;
      if (quizAnswers.isNotEmpty) {
        final totalQuizzes = quizAnswers.length;
        final correctAnswers = quizAnswers.values.where((answer) => answer == 0).length; // Assuming correct answer is 0
        score = totalQuizzes > 0 ? (correctAnswers / totalQuizzes * 100).round() : 100;
      }
      
      // Mark lesson/episode as completed
      final progressProvider = context.read<ProgressProvider>();
      if (widget.contentType == 'episode') {
        await progressProvider.completeEpisode(widget.title, score: score, timeSpent: timeSpent);
        print('🎉 Episode completed: ${widget.title} (Score: $score, Time: ${timeSpent}min)');
      } else {
        await progressProvider.completeLesson(widget.title, score: score, timeSpent: timeSpent);
        print('🎉 Lesson completed: ${widget.title} (Score: $score, Time: ${timeSpent}min)');
      }
    }
  }
} 