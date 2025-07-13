import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colorscheme.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/episode_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/content/page_viewer.dart';
import '../../widgets/lessons/card.dart';
import '../../widgets/lessons/searchbar.dart';
import '../../widgets/content/create_content_button.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize lessons, episodes and progress when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().initialize();
      context.read<EpisodeProvider>().initialize();
      context.read<ProgressProvider>().initialize();
    });
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColorScheme.secondaryVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 14,
            color: AppColorScheme.secondaryVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: SafeArea(
        child: Consumer2<LessonProvider, EpisodeProvider>(
          builder: (context, lessonProvider, episodeProvider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await lessonProvider.refreshLessons();
                await episodeProvider.refreshEpisodes();
              },
              color: AppColorScheme.accent,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColorScheme.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.play_circle_filled_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Learn & Watch',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                'Interactive lessons and engaging episodes',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColorScheme.secondaryVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Progress Tracking Card
                    Consumer<ProgressProvider>(
                      builder: (context, progressProvider, child) {
                        final progress = progressProvider.getProgressSummary();
                        
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorScheme.accent.withOpacity(0.1),
                                AppColorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColorScheme.accent.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColorScheme.accent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Your Progress',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColorScheme.onPrimary,
                                          ),
                                        ),
                                        Text(
                                          progressProvider.currentStreak > 0 
                                            ? '${progressProvider.currentStreak} day streak! Keep it up!'
                                            : 'Start your learning journey!',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColorScheme.secondaryVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Overall Progress Circle
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: CircularProgressIndicator(
                                            value: progress['completionPercentage'] / 100,
                                            strokeWidth: 8,
                                            backgroundColor: AppColorScheme.accent.withOpacity(0.2),
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColorScheme.accent),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${progress['completionPercentage']}%',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColorScheme.onPrimary,
                                              ),
                                            ),
                                            const Text(
                                              'Complete',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColorScheme.secondaryVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Stats
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildStatRow('Lessons Completed', '${progress['completedLessons']}', Icons.check_circle),
                                        const SizedBox(height: 8),
                                        _buildStatRow('Episodes Watched', '${progress['completedEpisodes']}', Icons.play_circle),
                                        const SizedBox(height: 8),
                                        _buildStatRow('Current Streak', '${progress['currentStreak']} days', Icons.local_fire_department),
                                        const SizedBox(height: 8),
                                        _buildStatRow('Total Time', progress['totalTime'], Icons.access_time),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Search Bar
                    LessonSearchBar(
                      onSearchChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Check if either provider is loading
                    if (lessonProvider.isLoading || episodeProvider.isLoading)
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColorScheme.accent,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading content...',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColorScheme.secondaryVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    
                    // Check for errors
                    else if (lessonProvider.error != null || episodeProvider.error != null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading content',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lessonProvider.error ?? episodeProvider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColorScheme.secondaryVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                lessonProvider.refreshLessons();
                                episodeProvider.refreshEpisodes();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorScheme.accent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    
                    // Content list
                    else ...[
                      // Combine and filter content
                      Builder(
                        builder: (context) {
                          final filteredLessons = lessonProvider.searchLessons(_searchQuery);
                          final filteredEpisodes = episodeProvider.searchEpisodes(_searchQuery);
                          
                          // Combine both lists and sort by title
                          final allContent = [...filteredLessons, ...filteredEpisodes];
                          allContent.sort((a, b) => (a['title'] ?? '').compareTo(b['title'] ?? ''));

                          if (allContent.isEmpty) {
                            if (_searchQuery.isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: AppColorScheme.secondaryVariant.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No content found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorScheme.secondaryVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your search terms',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColorScheme.secondaryVariant.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.library_books,
                                      size: 64,
                                      color: AppColorScheme.secondaryVariant.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No content available',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorScheme.secondaryVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Lessons and episodes will appear here once they\'re generated',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColorScheme.secondaryVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }

                          return Column(
                            children: allContent.map((content) {
                              final isEpisode = content['type'] == 'episode';
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: LessonCard(
                                  title: content['title'] ?? 'Untitled',
                                  subtitle: content['subtitle'] ?? 'No description',
                                  emoji: content['emoji'] ?? (isEpisode ? '📺' : '📚'),
                                  type: content['type'],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PageViewer(
                                          pages: List<Map<String, dynamic>>.from(content['pages'] ?? []),
                                          title: content['title'] ?? 'Untitled',
                                          emoji: content['emoji'] ?? (isEpisode ? '📺' : '📚'),
                                          contentType: isEpisode ? 'episode' : 'lesson',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: CreateContentButton(
        onCreated: (content, type) {
          // Optionally refresh your provider or show a snackbar
          // Example: context.read<EpisodeProvider>().refreshEpisodes();
          // Or: context.read<LessonProvider>().refreshLessons();
          // Or: show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${type == "lesson" ? "Lesson" : "Episode"} created!'), ),
          );
        },
      ),
    );
  }
}
