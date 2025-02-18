import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task3/models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> register(UserModel user) async {
    state = AuthState.loading();
    try {
      // Validate required fields
      if (user.email.isEmpty ||
          user.fullName.isEmpty ||
          user.phoneNumber.isEmpty ||
          user.password.isEmpty) {
        throw Exception('All fields are required');
      }

      final box = Hive.box<UserModel>('userBox');

      // Check if email already exists
      final existingUser = box.values.any((u) => u.email == user.email);
      if (existingUser) {
        throw Exception('Email already registered');
      }

      // Save user with proper error handling
      try {
        await box.add(user);
        state = AuthState.authenticated(user);
      } catch (e) {
        throw Exception('Failed to save user: ${e.toString()}');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      final box = Hive.box<UserModel>('userBox');

      // Safely get users
      List<UserModel> users;
      try {
        users = box.values.toList();
      } catch (e) {
        throw Exception('Error accessing user data');
      }

      // Find matching user
      final user = users.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );

      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void logout() async {
    try {
      final box = Hive.box<bool>('appBox');
      await box.put('isLoggedIn', false);
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error('Logout failed: ${e.toString()}');
    }
  }
}

class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;

  AuthState({
    required this.isLoading,
    this.error,
    this.user,
  });

  factory AuthState.initial() {
    return AuthState(isLoading: false);
  }

  factory AuthState.loading() {
    return AuthState(isLoading: true);
  }

  factory AuthState.authenticated(UserModel user) {
    return AuthState(isLoading: false, user: user);
  }

  factory AuthState.error(String error) {
    return AuthState(isLoading: false, error: error);
  }
}
