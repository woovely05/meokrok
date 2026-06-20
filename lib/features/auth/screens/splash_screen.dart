import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/model_downloader.dart';
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
  bool _modelReady = false;
  bool _isDownloading = false;
  bool _downloadFailed = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';
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

    _checkAndDownloadModel();

    _authSub = ref.listenManual(authProvider, (prev, next) {
      if (next.status != AuthStatus.loading) {
        _tryNavigate();
      }
    });
  }

  Future<void> _checkAndDownloadModel() async {
    if (await isModelReady()) {
      if (!mounted) return;
      setState(() => _modelReady = true);
      _tryNavigate();
      return;
    }

    if (!mounted) return;
    setState(() {
      _isDownloading = true;
      _downloadFailed = false;
      _downloadStatus = 'AI 모델 준비 중...';
    });

    try {
      await for (final (received, total) in downloadModel()) {
        if (!mounted) return;
        final receivedMb = received / 1024 / 1024;
        final totalMb = total > 0 ? total / 1024 / 1024 : 0.0;
        setState(() {
          _downloadProgress = total > 0 ? received / total : 0.0;
          _downloadStatus = totalMb > 0
              ? '${receivedMb.toStringAsFixed(0)} / ${totalMb.toStringAsFixed(0)} MB'
              : '${receivedMb.toStringAsFixed(0)} MB';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadFailed = true;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isDownloading = false;
      _modelReady = true;
    });
    _tryNavigate();
  }

  void _skipAiDownload() {
    setState(() {
      _downloadFailed = false;
      _modelReady = true;
    });
    _tryNavigate();
  }

  void _tryNavigate() {
    if (!mounted || _navigated || !_modelReady) return;

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
    final splashColor = AppColors.of(context).primary;
    return Scaffold(
      backgroundColor: splashColor,
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
            if (_downloadFailed) ...[
              Text(
                '다운로드에 실패했어요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _checkAndDownloadModel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '다시 시도',
                        style: TextStyle(
                          fontSize: 12,
                          color: splashColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _skipAiDownload,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'AI 없이 시작',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_isDownloading) ...[
              SizedBox(
                width: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _downloadStatus,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ] else ...[
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
                      color: Colors.white
                          .withValues(alpha: isActive ? 0.9 : 0.3),
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
          ],
        ),
      ),
    );
  }
}