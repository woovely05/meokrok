import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text, _pwCtrl.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    final auth = ref.read(authProvider);
    if (!auth.isOnboardingComplete) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 52),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🥗', style: TextStyle(fontSize: 44)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '먹록',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '매일 기록하는 건강한 식습관',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          color: colors.textGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 52),
                Text(
                  '로그인',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '이메일과 비밀번호를 입력해주세요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    color: colors.textGrey,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: '이메일',
                  controller: _emailCtrl,
                  placeholder: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '이메일을 입력해주세요';
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) {
                      return '유효한 이메일을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: '비밀번호',
                  controller: _pwCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                      color: colors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: '로그인',
                  onPressed: _login,
                  isLoading: _loading,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: colors.divider, thickness: 0.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '또는',
                        style: GoogleFonts.notoSansKr(
                            fontSize: 10, color: colors.textGrey),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: colors.divider, thickness: 0.5)),
                  ],
                ),
                const SizedBox(height: 16),
                AppSecondaryButton(
                  label: '이메일로 회원가입',
                  icon: Icon(Icons.email_outlined,
                      size: 14, color: colors.textDark),
                  onPressed: () => context.push('/signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
