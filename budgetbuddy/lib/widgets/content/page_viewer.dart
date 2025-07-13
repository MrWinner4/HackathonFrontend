import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../colorscheme.dart';

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

class _PageViewerState extends State<PageViewer> {
  int currentPageIndex = 0;
  List<String> userChoices = [];
  Map<String, dynamic> quizAnswers = {};

  @override
  Widget build(BuildContext context) {
    final currentPage = widget.pages[currentPageIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.emoji} ${widget.title}'),
        backgroundColor: AppColorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${currentPageIndex + 1}/${widget.pages.length}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Page content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    Text(
                      currentPage['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Page content with markdown
                    MarkdownBody(
                      data: currentPage['content'],
                      styleSheet: MarkdownStyleSheet(
                        h1: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: AppColorScheme.primary,
                        ),
                        h2: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: AppColorScheme.primary,
                        ),
                        h3: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: AppColorScheme.primary,
                        ),
                        p: const TextStyle(fontSize: 16, height: 1.5),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                        em: const TextStyle(fontStyle: FontStyle.italic),
                        blockquote: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    
                    // Interactive elements (quizzes, etc.)
                    if (currentPage['interactive_elements'] != null) ...[
                      const SizedBox(height: 24),
                      ...currentPage['interactive_elements'].map<Widget>((element) => 
                        _buildInteractiveElement(element, currentPage['id']),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Navigation/Choices section
            const SizedBox(height: 20),
            _buildNavigationSection(currentPage),
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
    final userAnswer = quizAnswers[pageId];
    final isAnswered = userAnswer != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorScheme.primaryVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColorScheme.primaryVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤔 $question',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = userAnswer == index;
            final isCorrect = index == correctAnswer;
            
            Color backgroundColor = Colors.white;
            Color borderColor = Colors.grey.shade300;
            
            if (isAnswered) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
              } else if (isSelected) {
                backgroundColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red;
              }
            } else if (isSelected) {
              backgroundColor = AppColorScheme.accent.withOpacity(0.1);
              borderColor = AppColorScheme.accent;
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: isAnswered ? null : () => _answerQuiz(pageId, index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAnswered && isCorrect 
                          ? Icons.check_circle 
                          : isAnswered && isSelected 
                            ? Icons.cancel 
                            : Icons.radio_button_unchecked,
                        color: isAnswered && isCorrect 
                          ? Colors.green 
                          : isAnswered && isSelected 
                            ? Colors.red 
                            : AppColorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(option)),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (isAnswered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: correctAnswer == userAnswer 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                correctAnswer == userAnswer 
                  ? '✅ Correct! Well done!' 
                  : '❌ Not quite right. The correct answer is: ${options[correctAnswer]}',
                style: TextStyle(
                  color: correctAnswer == userAnswer ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationSection(Map<String, dynamic> currentPage) {
    // For stories with choices
    if (currentPage['choices'] != null) {
      return Column(
        children: currentPage['choices'].map<Widget>((choice) => 
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () => _makeChoice(choice),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                choice['text'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }
    
    // For lessons with standard navigation
    return Row(
      children: [
        if (currentPageIndex > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => currentPageIndex--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (currentPageIndex < widget.pages.length - 1) ...[
          if (currentPageIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => currentPageIndex++),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.primary,
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
      ],
    );
  }

  void _makeChoice(Map<String, dynamic> choice) {
    setState(() {
      userChoices.add(choice['text']);
      // Find the next page
      final nextPageId = choice['next_page'];
      final nextPageIndex = widget.pages.indexWhere((page) => page['id'] == nextPageId);
      if (nextPageIndex != -1) {
        currentPageIndex = nextPageIndex;
      }
    });
  }

  void _answerQuiz(String pageId, int answer) {
    setState(() {
      quizAnswers[pageId] = answer;
    });
  }
} 