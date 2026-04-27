import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  int _activeDot = 0;
  Timer? _dotTimer;

  bool _isReady = false;
  bool _navigated = false;
  ProviderSubscription<AuthState>? _authSub;

  String _loadingText = "불러오는 중";

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;

      setState(() {
        _activeDot = (_activeDot + 1) % 3;
        _loadingText = '불러오는 중${"." * (_activeDot + 1)}';
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      _isReady = true;
      _tryNavigate();
    });

    _authSub = ref.listenManual(authProvider, (prev, next) {
      if (next.status != AuthStatus.loading) {
        _tryNavigate();
      }
    });
  }

  void _tryNavigate() {
    if (!mounted || _navigated) return;

    final auth = ref.read(authProvider);

    if (auth.status == AuthStatus.loading) {
      _updateLoadingMessage(auth);
      return;
    }

    if (!_isReady) return;

    _navigated = true;

    if (auth.status == AuthStatus.authenticated) {
      if (!auth.isOnboardingComplete) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    } else {
      context.go('/login');
    }
  }

  void _updateLoadingMessage(AuthState auth) {
    if (!mounted) return;

    setState(() {
      _loadingText = "사용자 정보 확인 중";
    });
  }

  @override
  void dispose() {
    _authSub?.close();
    _dotController.dispose();
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🥗', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '먹록',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '나만의 식습관 루틴',
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final isActive = i == _activeDot;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 13 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: isActive ? 0.9 : 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _loadingText,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}