import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  static const String _storageKey = 'chat_messages';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _loadMessages();
  }

  // Load messages from persistent storage
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList(_storageKey) ?? [];
      
      _messages = messagesJson
          .map((json) => ChatMessage.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading messages: $e');
      }
    }
  }

  // Save messages to persistent storage
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages
          .map((msg) => jsonEncode(msg.toJson()))
          .toList();
      
      await prefs.setStringList(_storageKey, messagesJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving messages: $e');
      }
    }
  }

  // Add a new message
  Future<void> addMessage(String text, bool isUser) async {
    final message = ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    
    _messages.add(message);
    notifyListeners();
    await _saveMessages();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear all messages
  Future<void> clearMessages() async {
    _messages.clear();
    notifyListeners();
    await _saveMessages();
  }

  // Get messages count
  int get messageCount => _messages.length;

  // Check if there are any messages
  bool get hasMessages => _messages.isNotEmpty;
} 