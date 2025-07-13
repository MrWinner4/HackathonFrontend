import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressProvider with ChangeNotifier {
  static const String _progressKey = 'user_progress';
  static const String _lastCompletedKey = 'last_completed_date';
  
  Map<String, dynamic> _progress = {
    'completedLessons': <String>[],
    'completedEpisodes': <String>[],
    'totalTimeSpent': 0, // in minutes
    'currentStreak': 0,
    'longestStreak': 0,
    'lastCompletedDate': null,
    'lessonScores': <String, int>{}, // lessonId -> score
    'episodeScores': <String, int>{}, // episodeId -> score
  };

  // Getters
  List<String> get completedLessons => _progress['completedLessons'] ?? [];
  List<String> get completedEpisodes => _progress['completedEpisodes'] ?? [];
  int get totalTimeSpent => _progress['totalTimeSpent'] ?? 0;
  int get currentStreak => _progress['currentStreak'] ?? 0;
  int get longestStreak => _progress['longestStreak'] ?? 0;
  Map<String, int> get lessonScores => _progress['lessonScores'] ?? {};
  Map<String, int> get episodeScores => _progress['episodeScores'] ?? {};
  
  // Computed values
  int get completedLessonsCount => completedLessons.length;
  int get completedEpisodesCount => completedEpisodes.length;
  int get totalCompletedCount => completedLessonsCount + completedEpisodesCount;
  double get completionPercentage => totalCompletedCount > 0 ? (totalCompletedCount / 40) * 100 : 0; // Assuming 40 total content items
  String get totalTimeFormatted {
    final hours = totalTimeSpent ~/ 60;
    final minutes = totalTimeSpent % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Initialize provider
  Future<void> initialize() async {
    await _loadProgress();
  }

  // Load progress from SharedPreferences
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      if (progressJson != null) {
        final loadedProgress = Map<String, dynamic>.from(json.decode(progressJson));
        
        // Fix type casting for completedLessons
        final completedLessonsData = loadedProgress['completedLessons'];
        if (completedLessonsData is List) {
          loadedProgress['completedLessons'] = completedLessonsData.cast<String>();
        } else {
          loadedProgress['completedLessons'] = <String>[];
        }
        
        // Fix type casting for completedEpisodes
        final completedEpisodesData = loadedProgress['completedEpisodes'];
        if (completedEpisodesData is List) {
          loadedProgress['completedEpisodes'] = completedEpisodesData.cast<String>();
        } else {
          loadedProgress['completedEpisodes'] = <String>[];
        }
        
        // Fix type casting for lessonScores
        final lessonScoresData = loadedProgress['lessonScores'];
        if (lessonScoresData is Map) {
          loadedProgress['lessonScores'] = Map<String, int>.from(lessonScoresData);
        } else {
          loadedProgress['lessonScores'] = <String, int>{};
        }
        
        // Fix type casting for episodeScores
        final episodeScoresData = loadedProgress['episodeScores'];
        if (episodeScoresData is Map) {
          loadedProgress['episodeScores'] = Map<String, int>.from(episodeScoresData);
        } else {
          loadedProgress['episodeScores'] = <String, int>{};
        }
        
        _progress = loadedProgress;
        _updateStreak();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error loading progress: $e');
      // Reset to default if loading fails
      _progress = {
        'completedLessons': <String>[],
        'completedEpisodes': <String>[],
        'totalTimeSpent': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastCompletedDate': null,
        'lessonScores': <String, int>{},
        'episodeScores': <String, int>{},
      };
    }
  }

  // Save progress to SharedPreferences
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, json.encode(_progress));
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  // Mark lesson as completed
  Future<void> completeLesson(String lessonId, {int score = 100, int timeSpent = 0}) async {
    if (!completedLessons.contains(lessonId)) {
      _progress['completedLessons'].add(lessonId);
      _progress['totalTimeSpent'] = totalTimeSpent + timeSpent;
      _progress['lessonScores'][lessonId] = score;
      _progress['lastCompletedDate'] = DateTime.now().toIso8601String();
      
      print('📊 Before streak update: Current streak = $currentStreak, Total time = $totalTimeSpent');
      _updateStreak();
      print('📊 After streak update: Current streak = ${_progress['currentStreak']}, Total time = ${_progress['totalTimeSpent']}');
      
      await _saveProgress();
      notifyListeners();
      
      print('✅ Lesson completed: $lessonId (Score: $score, Time: ${timeSpent}min)');
    }
  }

  // Mark episode as completed
  Future<void> completeEpisode(String episodeId, {int score = 100, int timeSpent = 0}) async {
    if (!completedEpisodes.contains(episodeId)) {
      _progress['completedEpisodes'].add(episodeId);
      _progress['totalTimeSpent'] = totalTimeSpent + timeSpent;
      _progress['episodeScores'][episodeId] = score;
      _progress['lastCompletedDate'] = DateTime.now().toIso8601String();
      
      print('📊 Before streak update: Current streak = $currentStreak, Total time = $totalTimeSpent');
      _updateStreak();
      print('📊 After streak update: Current streak = ${_progress['currentStreak']}, Total time = ${_progress['totalTimeSpent']}');
      
      await _saveProgress();
      notifyListeners();
      
      print('✅ Episode completed: $episodeId (Score: $score, Time: ${timeSpent}min)');
    }
  }

  // Update streak based on completion dates
  void _updateStreak() {
    final lastCompleted = _progress['lastCompletedDate'];
    if (lastCompleted == null) {
      _progress['currentStreak'] = 1; // First lesson completed
      return;
    }

    final lastDate = DateTime.parse(lastCompleted);
    final today = DateTime.now();
    final difference = today.difference(lastDate).inDays;

    if (difference == 0) {
      // Completed today, maintain current streak
      _progress['currentStreak'] = currentStreak;
    } else if (difference == 1) {
      // Completed yesterday, increment streak
      _progress['currentStreak'] = currentStreak + 1;
    } else if (difference > 1) {
      // Streak broken, start new streak
      _progress['currentStreak'] = 1;
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      _progress['longestStreak'] = currentStreak;
    }
  }

  // Check if lesson is completed
  bool isLessonCompleted(String lessonId) {
    return completedLessons.contains(lessonId);
  }

  // Check if episode is completed
  bool isEpisodeCompleted(String episodeId) {
    return completedEpisodes.contains(episodeId);
  }

  // Get lesson score
  int getLessonScore(String lessonId) {
    return lessonScores[lessonId] ?? 0;
  }

  // Get episode score
  int getEpisodeScore(String episodeId) {
    return episodeScores[episodeId] ?? 0;
  }

  // Add time spent on lesson
  Future<void> addTimeSpent(int minutes) async {
    _progress['totalTimeSpent'] = totalTimeSpent + minutes;
    await _saveProgress();
    notifyListeners();
  }

  // Reset progress (for testing)
  Future<void> resetProgress() async {
    _progress = {
      'completedLessons': <String>[],
      'completedEpisodes': <String>[],
      'totalTimeSpent': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'lastCompletedDate': null,
      'lessonScores': <String, int>{},
      'episodeScores': <String, int>{},
    };
    await _saveProgress();
    notifyListeners();
  }

  // Get progress summary for display
  Map<String, dynamic> getProgressSummary() {
    return {
      'completedLessons': completedLessonsCount,
      'completedEpisodes': completedEpisodesCount,
      'totalCompleted': totalCompletedCount,
      'totalTime': totalTimeFormatted,
      'currentStreak': currentStreak,
      'completionPercentage': completionPercentage.round(),
      'longestStreak': longestStreak,
    };
  }

  // Get recent activity
  List<Map<String, dynamic>> getRecentActivity() {
    final recent = <Map<String, dynamic>>[];
    for (final lessonId in completedLessons.take(5)) {
      recent.add({
        'lessonId': lessonId,
        'score': getLessonScore(lessonId),
        'completed': true,
      });
    }
    return recent;
  }
} 