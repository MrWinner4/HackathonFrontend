import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colorscheme.dart';
import '../../providers/progress_provider.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final String? type; // 'lesson' or 'episode'
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        final isEpisode = type == 'episode';
        final isCompleted = isEpisode 
          ? progressProvider.isEpisodeCompleted(title)
          : progressProvider.isLessonCompleted(title);
        final accentColor = isEpisode ? AppColorScheme.accentVariant : AppColorScheme.accent;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isCompleted 
                    ? accentColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                  width: isCompleted ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isCompleted 
                        ? accentColor.withOpacity(0.2)
                        : accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        if (isCompleted)
                          Positioned(
                            top: 0,
                            right: 0,
                                                          child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                                                  color: isCompleted 
                                  ? accentColor
                                  : AppColorScheme.onPrimary,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isEpisode ? 'Watched' : 'Completed',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColorScheme.secondaryVariant,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isEpisode ? 'Episode' : 'Lesson',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColorScheme.secondaryVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
