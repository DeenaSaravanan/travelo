import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final navigationManagerProvider = Provider<NavigationManager>((ref) {
  return NavigationManager();
});

class NavigationManager {
  Future<String> getInitialRoute() async {
    try {
      final box = Hive.box<bool>('appBox');

      // Use explicit boolean values with proper null checking
      final hasSeenOnboarding = box.get('hasSeenOnboarding') ?? false;
      final isLoggedIn = box.get('isLoggedIn') ?? false;

      if (!hasSeenOnboarding) {
        return '/onboarding';
      }

      if (!isLoggedIn) {
        return '/login';
      }

      return '/home';
    } catch (e) {
      // If there's any error, return to splash screen
      return '/splash';
    }
  }

  Future<void> markOnboardingComplete() async {
    try {
      final box = Hive.box<bool>('appBox');
      await box.put('hasSeenOnboarding', true);
    } catch (e) {
      // Handle error appropriately
      print('Error marking onboarding complete: $e');
      rethrow;
    }
  }

  Future<void> markUserLoggedIn(bool value) async {
    try {
      final box = Hive.box<bool>('appBox');
      await box.put('isLoggedIn', value);
    } catch (e) {
      // Handle error appropriately
      print('Error marking user login status: $e');
      rethrow;
    }
  }
}
