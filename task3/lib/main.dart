// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task3/models/user_model.dart';
import 'package:task3/navigation_manager.dart';
import 'package:task3/screens/home_screen.dart';
import 'package:task3/screens/login_screen.dart';
import 'package:task3/screens/onboarding_screen.dart';
import 'package:task3/screens/otp_verification_screen.dart';
import 'package:task3/screens/register_screen.dart';
import 'package:task3/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the adapter only if it hasn't been registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  // Close boxes if they're already open
  if (Hive.isBoxOpen('userBox')) {
    await Hive.box('userBox').close();
  }
  if (Hive.isBoxOpen('appBox')) {
    await Hive.box('appBox').close();
  }

  // Open boxes with explicit types
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<bool>('appBox');

  runApp(
    const ProviderScope(
      child: TravelloApp(),
    ),
  );
}

class TravelloApp extends ConsumerStatefulWidget {
  const TravelloApp({Key? key}) : super(key: key);

  @override
  ConsumerState<TravelloApp> createState() => _TravelloAppState();
}

class _TravelloAppState extends ConsumerState<TravelloApp> {
  late Future<String> _initialRouteFuture;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = ref.read(navigationManagerProvider).getInitialRoute();
    _handleSplashScreen();
  }

  void _handleSplashScreen() async {
    // Show splash screen for 5 seconds
    await Future.delayed(const Duration(seconds: 10));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travello',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFF4D67),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4D67),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: _showSplash
          ? const SplashScreen()
          : FutureBuilder<String>(
              future: _initialRouteFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SplashScreen();
                }

                final initialRoute = snapshot.data ?? '/splash';
                return _buildInitialScreen(initialRoute);
              },
            ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/otp-verification':
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(email: email),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(
                builder: (context) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/onboarding':
            return MaterialPageRoute(
                builder: (context) => const OnboardingScreen());
          default:
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
        }
      },
    );
  }

  Widget _buildInitialScreen(String route) {
    switch (route) {
      case '/onboarding':
        return const OnboardingScreen();
      case '/login':
        return const LoginScreen();
      case '/home':
        return const HomeScreen();
      default:
        return const SplashScreen();
    }
  }
}
