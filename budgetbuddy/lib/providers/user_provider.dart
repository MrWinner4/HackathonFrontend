import 'package:budgetbuddy/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class UserData {
  final String id;
  final String username;
  final String email;
  final double balance;
  final List<Goal> goals;
  final bool notificationsEnabled;
  final bool darkMode;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.balance,
    required this.goals,
    required this.notificationsEnabled,
    required this.darkMode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      balance: (json['piggy_bank']?['balance'] ?? 0.0).toDouble(),
      goals: (json['goals'] as List<dynamic>? ?? [])
          .map((goal) => Goal.fromJson(goal))
          .toList(),
      notificationsEnabled: json['settings']?['notifications_enabled'] ?? true,
      darkMode: json['settings']?['dark_mode'] ?? false,
    );
  }
}

class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final DateTime? dueDate;
  final DateTime createdAt;
  double? currentAmount; // This will be calculated based on progress

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.dueDate,
    required this.createdAt,
    this.currentAmount,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      targetAmount: (json['target_amount'] ?? 0.0).toDouble(),
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      currentAmount: (json['current_amount'] ?? 0.0).toDouble(),
    );
  }

  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount ?? 0.0) / targetAmount;
  }

  String get emoji {
    // Simple emoji mapping based on goal name
    final goalName = name.toLowerCase();
    if (goalName.contains('bike') || goalName.contains('car')) return '🚲';
    if (goalName.contains('vacation') || goalName.contains('trip')) return '🏖️';
    if (goalName.contains('laptop') || goalName.contains('computer')) return '💻';
    if (goalName.contains('phone')) return '📱';
    if (goalName.contains('house') || goalName.contains('home')) return '🏠';
    if (goalName.contains('game') || goalName.contains('console')) return '🎮';
    if (goalName.contains('book') || goalName.contains('study')) return '📚';
    if (goalName.contains('music') || goalName.contains('instrument')) return '🎸';
    return '🎯'; // default
  }
}

class UserProvider with ChangeNotifier {
  UserData? _userData;
  bool _isLoading = false;
  String? _error;
  final Dio _dio = Dio();

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String get username => _userData?.username ?? 'User';
  double get balance => _userData?.balance ?? 0.0;
  List<Goal> get goals => _userData?.goals ?? [];

  Future<void> fetchUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('$backendBaseUrl/users/me');
      
      if (response.statusCode == 200) {
        _userData = UserData.fromJson(response.data);
        _error = null;
      } else {
        _error = 'Failed to fetch user data';
      }
    } catch (e) {
      _error = 'Error fetching user data: $e';
      print('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBalance(double newBalance) async {
    try {
      if (kDebugMode) {
        print('updateBalance: userData.id = ${_userData?.id} (type: ${_userData?.id.runtimeType})');
      }
      final response = await _dio.put(
        '$backendBaseUrl/users/${_userData?.id}/piggy_bank',
        data: {'balance': newBalance},
      );
      
      if (response.statusCode == 200) {
        print(response.data);
        // Fetch the latest user data to ensure UI is in sync with backend
        await fetchUserData();
      }
    } catch (e) {
      _error = 'Error updating balance: $e';
      notifyListeners();
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      final response = await _dio.put(
        '$backendBaseUrl/users/${_userData?.id}',
        data: {'username': newUsername},
      );
      
      if (response.statusCode == 200) {
        _userData = _userData?.copyWith(username: newUsername);
        notifyListeners();
      } else {
        _error = 'Failed to update username';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error updating username: $e';
      notifyListeners();
    }
  }

  Future<void> addGoal(String name, double targetAmount, DateTime? dueDate) async {
    try {
      final response = await _dio.post(
        '$backendBaseUrl/goals/',
        data: {
          'name': name,
          'target_amount': targetAmount,
          'due_date': dueDate?.toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        final newGoal = Goal.fromJson(response.data);
        _userData = _userData?.copyWith(
          goals: [...(_userData?.goals ?? []), newGoal],
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error adding goal: $e';
      notifyListeners();
    }
  }

  Future<void> updateGoal(String goalId, String name, double targetAmount, DateTime? dueDate) async {
    try {
      final response = await _dio.put(
        '$backendBaseUrl/goals/$goalId',
        data: {
          'name': name,
          'target_amount': targetAmount,
          'due_date': dueDate?.toIso8601String(),
        },
      );
      
      if (response.statusCode == 200) {
        final updatedGoal = Goal.fromJson(response.data);
        final updatedGoals = (_userData?.goals ?? []).map((goal) {
          return goal.id == goalId ? updatedGoal : goal;
        }).toList();
        
        _userData = _userData?.copyWith(goals: updatedGoals);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error updating goal: $e';
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      final response = await _dio.delete('$backendBaseUrl/goals/$goalId');
      
      if (response.statusCode == 200) {
        final updatedGoals = (_userData?.goals ?? []).where((goal) => goal.id != goalId).toList();
        _userData = _userData?.copyWith(goals: updatedGoals);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error deleting goal: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add this method to allow local balance update
  void updateLocalBalance(double newBalance) {
    if (_userData != null) {
      _userData = _userData!.copyWith(balance: newBalance);
      notifyListeners();
    }
  }
}

extension UserDataCopyWith on UserData {
  UserData copyWith({
    String? id,
    String? username,
    String? email,
    double? balance,
    List<Goal>? goals,
    bool? notificationsEnabled,
    bool? darkMode,

  }) {
    return UserData(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      goals: goals ?? this.goals,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
