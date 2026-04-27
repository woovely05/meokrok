import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/meal_log/screens/meal_log_screen.dart';
import '../../features/analysis/screens/analysis_screen.dart';
import '../../features/auth/screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: kDebugMode,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/mypage', builder: (_, _) => const ProfileScreen()),
    GoRoute(
      path: '/meal-log/:date',
      builder: (_, state) =>
          MealLogScreen(dateStr: state.pathParameters['date']!),
    ),
    GoRoute(
      path: '/analysis/:date',
      builder: (_, state) =>
          AnalysisScreen(dateStr: state.pathParameters['date']!),
    ),
  ],
);
