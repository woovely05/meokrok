import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  Gender _gender = Gender.male;
  Goal _goal = Goal.maintain;

  final _heightCtrl = TextEditingController(text: '170');
  final _weightCtrl = TextEditingController(text: '65');
  final _ageCtrl = TextEditingController(text: '25');

  bool _loading = false;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    setState(() => _loading = true);
    final user = ref.read(authProvider).user!;
    final updated = user.copyWith(
      gender: _gender,
      height: double.tryParse(_heightCtrl.text) ?? 170,
      weight: double.tryParse(_weightCtrl.text) ?? 65,
      age: int.tryParse(_ageCtrl.text) ?? 25,
      goal: _goal,
    );
    await ref.read(authProvider.notifier).saveProfile(updated);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressBar(step: _step),
              const SizedBox(height: 8),
              Text(
                '${_step + 1} / 3 단계',
                style: GoogleFonts.notoSansKr(
                    fontSize: 8.5, color: colors.textGrey),
              ),
              const SizedBox(height: 20),
              Text(
                '내 신체 정보를\n알려주세요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.textDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildStepContent()),
              const SizedBox(height: 16),
              AppPrimaryButton(
                label: _step < 2 ? '다음' : '시작하기',
                onPressed: _next,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return switch (_step) {
      0 => _Step1Body(
          heightCtrl: _heightCtrl,
          weightCtrl: _weightCtrl,
        ),
      1 => _Step2AgeGender(
          ageCtrl: _ageCtrl,
          gender: _gender,
          onGenderChanged: (g) => setState(() => _gender = g),
        ),
      _ => _Step3Goal(
          goal: _goal,
          onGoalChanged: (g) => setState(() => _goal = g),
        ),
    };
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            height: 2.5,
            decoration: BoxDecoration(
              color: i <= step ? colors.primary : colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.controller,
    required this.unit,
  });

  final String label;
  final TextEditingController controller;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 9,
              color: colors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: colors.cardBg,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.notoSansKr(
                  fontSize: 10,
                  color: colors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step1Body extends StatelessWidget {
  const _Step1Body({
    required this.heightCtrl,
    required this.weightCtrl,
  });

  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child:
                    _InfoCard(label: '키', controller: heightCtrl, unit: 'cm')),
            const SizedBox(width: 10),
            Expanded(
                child: _InfoCard(
                    label: '몸무게', controller: weightCtrl, unit: 'kg')),
          ],
        ),
      ],
    );
  }
}

class _Step2AgeGender extends StatelessWidget {
  const _Step2AgeGender({
    required this.ageCtrl,
    required this.gender,
    required this.onGenderChanged,
  });

  final TextEditingController ageCtrl;
  final Gender gender;
  final ValueChanged<Gender> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(label: '나이', controller: ageCtrl, unit: '세'),
        const SizedBox(height: 16),
        Row(
          children: [
            _GenderButton(
              label: '남성',
              selected: gender == Gender.male,
              onTap: () => onGenderChanged(Gender.male),
            ),
            const SizedBox(width: 10),
            _GenderButton(
              label: '여성',
              selected: gender == Gender.female,
              onTap: () => onGenderChanged(Gender.female),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected ? colors.primaryLight : colors.secondaryButton,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? colors.primary : colors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step3Goal extends StatelessWidget {
  const _Step3Goal({
    required this.goal,
    required this.onGoalChanged,
  });

  final Goal goal;
  final ValueChanged<Goal> onGoalChanged;

  static const _goals = [
    (Goal.lose, '체중 감량', '🔥'),
    (Goal.maintain, '체중 유지', '⚖️'),
    (Goal.bulk, '벌크업', '💪'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: _goals
          .map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => onGoalChanged(g.$1),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: goal == g.$1
                          ? colors.primaryLight
                          : colors.secondaryButton,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: goal == g.$1 ? colors.primary : colors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(g.$3, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(
                          g.$2,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: goal == g.$1
                                ? colors.primary
                                : colors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
