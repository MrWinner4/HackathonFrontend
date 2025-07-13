import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/lesson_model.dart';

class LessonProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 30); // Cache for 30 minutes

  // Getters
  List<Map<String, dynamic>> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLessons => _lessons.isNotEmpty;
  bool get isCacheValid => _lastFetchTime != null && 
      DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;

  // Initialize provider
  Future<void> initialize() async {
    if (!isCacheValid) {
      await fetchLessons();
    }
  }

  // Fetch lessons from API
  Future<void> fetchLessons({bool forceRefresh = false}) async {
    if (!forceRefresh && isCacheValid && _lessons.isNotEmpty) {
      print('📚 Using cached lessons (${_lessons.length} lessons)');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🚀 Fetching lessons from API...');
      final response = await _apiService.get('/lessons/');
      
      if (response.statusCode == 200) {
        final lessonsData = List<Map<String, dynamic>>.from(response.data);
        
        _lessons = lessonsData.map((lesson) => {
          'title': lesson['title'] ?? 'Untitled Lesson',
          'subtitle': lesson['subtitle'] ?? 'No description available',
          'emoji': lesson['emoji'] ?? '📚',
          'pages': lesson['pages'] ?? [],
          'learning_objectives': lesson['learning_objectives'] ?? [],
          'topics': lesson['topics'] ?? [],
          'estimated_duration': lesson['estimated_duration'] ?? '5 min',
          'id': lesson['id'] ?? '',
          'type': 'lesson', // Add type to differentiate from episodes
        }).toList();
        
        _lastFetchTime = DateTime.now();
        print('✅ Successfully loaded ${_lessons.length} lessons from API');
        
        // If no lessons found, generate some test lessons
        if (_lessons.isEmpty) {
          print('📝 No lessons found, generating test lessons...');
          await _generateTestLessons();
        }
      }
    } catch (e) {
      print('❌ Error fetching lessons: $e');
      _setError('Failed to load lessons: $e');
      
      // Generate test lessons as fallback
      if (_lessons.isEmpty) {
        await _generateTestLessons();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Generate test lessons
  Future<void> _generateTestLessons() async {
    try {
      final topics = [
        'Budgeting Basics',
        'Saving Money',
        'Understanding Credit',
        'Investing Fundamentals',
        'Emergency Funds'
      ];
      
      for (final topic in topics) {
        try {
          final response = await _apiService.post('/lessons/generate', data: {
            'topic': topic,
            'content_type': 'lesson',
          });
          
          if (response.statusCode == 200) {
            final lesson = response.data;
            _lessons.add({
              'title': lesson['title'] ?? topic,
              'subtitle': lesson['subtitle'] ?? 'Learn about $topic',
              'emoji': lesson['emoji'] ?? '📚',
              'pages': lesson['pages'] ?? [],
              'learning_objectives': lesson['learning_objectives'] ?? [],
              'topics': lesson['topics'] ?? [],
              'estimated_duration': lesson['estimated_duration'] ?? '5 min',
              'id': lesson['id'] ?? '',
              'type': 'lesson',
            });
            print('✅ Generated lesson: $topic');
          }
        } catch (e) {
          print('❌ Failed to generate lesson for $topic: $e');
        }
      }
      
      _lastFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('❌ Error generating test lessons: $e');
      _setError('Failed to generate test lessons: $e');
    }
  }

  // Get a specific lesson by ID
  Map<String, dynamic>? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get lessons by topic
  List<Map<String, dynamic>> getLessonsByTopic(String topic) {
    return _lessons.where((lesson) {
      final topics = lesson['topics'] as List<dynamic>? ?? [];
      return topics.any((t) => t.toString().toLowerCase().contains(topic.toLowerCase()));
    }).toList();
  }

  // Search lessons
  List<Map<String, dynamic>> searchLessons(String query) {
    if (query.isEmpty) return _lessons;
    
    final lowercaseQuery = query.toLowerCase();
    return _lessons.where((lesson) {
      final title = lesson['title']?.toString().toLowerCase() ?? '';
      final subtitle = lesson['subtitle']?.toString().toLowerCase() ?? '';
      final topics = lesson['topics']?.toString().toLowerCase() ?? '';
      
      return title.contains(lowercaseQuery) || 
             subtitle.contains(lowercaseQuery) || 
             topics.contains(lowercaseQuery);
    }).toList();
  }

  // Refresh lessons (force API call)
  Future<void> refreshLessons() async {
    await fetchLessons(forceRefresh: true);
  }

  // Clear cache
  void clearCache() {
    _lessons.clear();
    _lastFetchTime = null;
    _clearError();
    notifyListeners();
  }

  // Get cache status
  Map<String, dynamic> getCacheStatus() {
    return {
      'hasLessons': hasLessons,
      'lessonCount': _lessons.length,
      'isCacheValid': isCacheValid,
      'lastFetchTime': _lastFetchTime?.toIso8601String(),
      'cacheAge': _lastFetchTime != null 
          ? DateTime.now().difference(_lastFetchTime!).inMinutes 
          : null,
    };
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }
} 