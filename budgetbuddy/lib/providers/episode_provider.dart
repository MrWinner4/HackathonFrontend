import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class EpisodeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _episodes = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 30); // Cache for 30 minutes

  // Getters
  List<Map<String, dynamic>> get episodes => _episodes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasEpisodes => _episodes.isNotEmpty;
  bool get isCacheValid => _lastFetchTime != null && 
      DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;

  // Initialize provider
  Future<void> initialize() async {
    if (!isCacheValid) {
      await fetchEpisodes();
    }
  }

  // Fetch episodes from API
  Future<void> fetchEpisodes({bool forceRefresh = false}) async {
    if (!forceRefresh && isCacheValid && _episodes.isNotEmpty) {
      print('📺 Using cached episodes (${_episodes.length} episodes)');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🚀 Fetching episodes from API...');
      final response = await _apiService.get('/stories/');
      
      if (response.statusCode == 200) {
        final episodesData = List<Map<String, dynamic>>.from(response.data);
        
        _episodes = episodesData.map((episode) => {
          'title': episode['title'] ?? 'Untitled Episode',
          'subtitle': episode['subtitle'] ?? 'No description available',
          'emoji': episode['emoji'] ?? '📺',
          'pages': episode['pages'] ?? [],
          'topics': episode['topics'] ?? [],
          'estimated_read_time': episode['estimated_read_time'] ?? '5 min',
          'id': episode['id'] ?? '',
          'type': 'episode', // Add type to differentiate from lessons
        }).toList();
        
        _lastFetchTime = DateTime.now();
        print('✅ Successfully loaded ${_episodes.length} episodes from API');
        
        // If no episodes found, generate some test episodes
        if (_episodes.isEmpty) {
          print('📝 No episodes found, generating test episodes...');
          await _generateTestEpisodes();
        }
      }
    } catch (e) {
      print('❌ Error fetching episodes: $e');
      _setError('Failed to load episodes: $e');
      
      // Generate test episodes as fallback
      if (_episodes.isEmpty) {
        await _generateTestEpisodes();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Generate test episodes
  Future<void> _generateTestEpisodes() async {
    try {
      final topics = [
        'The Magic of Compound Interest',
        'A Day in the Life of a Budget',
        'The Credit Card Adventure',
        'Saving for a Rainy Day',
        'Investing in Your Future'
      ];
      
      for (final topic in topics) {
        try {
          final response = await _apiService.post('/stories/generate', 
            data: {
              'topic': topic,
              'content_type': 'episode',
            }
          );
          
          if (response.statusCode == 200) {
            final episode = response.data;
            _episodes.add({
              'title': episode['title'] ?? topic,
              'subtitle': episode['subtitle'] ?? 'An interactive story about $topic',
              'emoji': episode['emoji'] ?? '📺',
              'pages': episode['pages'] ?? [],
              'topics': episode['topics'] ?? [],
              'estimated_read_time': episode['estimated_read_time'] ?? '5 min',
              'id': episode['id'] ?? '',
              'type': 'episode',
            });
            print('✅ Generated episode: $topic');
          }
        } catch (e) {
          print('❌ Failed to generate episode for $topic: $e');
        }
      }
      
      _lastFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('❌ Error generating test episodes: $e');
      _setError('Failed to generate test episodes: $e');
    }
  }

  // Get a specific episode by ID
  Map<String, dynamic>? getEpisodeById(String id) {
    try {
      return _episodes.firstWhere((episode) => episode['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get episodes by topic
  List<Map<String, dynamic>> getEpisodesByTopic(String topic) {
    return _episodes.where((episode) {
      final topics = episode['topics'] as List<dynamic>? ?? [];
      return topics.any((t) => t.toString().toLowerCase().contains(topic.toLowerCase()));
    }).toList();
  }

  // Search episodes
  List<Map<String, dynamic>> searchEpisodes(String query) {
    if (query.isEmpty) return _episodes;
    
    final lowercaseQuery = query.toLowerCase();
    return _episodes.where((episode) {
      final title = episode['title']?.toString().toLowerCase() ?? '';
      final subtitle = episode['subtitle']?.toString().toLowerCase() ?? '';
      final topics = episode['topics']?.toString().toLowerCase() ?? '';
      
      return title.contains(lowercaseQuery) || 
             subtitle.contains(lowercaseQuery) || 
             topics.contains(lowercaseQuery);
    }).toList();
  }

  // Refresh episodes (force API call)
  Future<void> refreshEpisodes() async {
    await fetchEpisodes(forceRefresh: true);
  }

  // Clear cache
  void clearCache() {
    _episodes.clear();
    _lastFetchTime = null;
    _clearError();
    notifyListeners();
  }

  // Get cache status
  Map<String, dynamic> getCacheStatus() {
    return {
      'hasEpisodes': hasEpisodes,
      'episodeCount': _episodes.length,
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