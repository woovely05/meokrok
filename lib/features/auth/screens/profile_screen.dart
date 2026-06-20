import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../widgets/profile_settings_card.dart';
import '../widgets/profile_weight_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final authState = ref.watch(authProvider);

    if (authState.status == AuthStatus.loading || authState.user == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    final user = authState.user!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          '마이페이지',
          style: GoogleFonts.notoSansKr(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(user: user),
            const SizedBox(height: 12),
            _BodyStatsRow(user: user),
            const SizedBox(height: 12),
            _CalorieGoalCard(user: user),
            const SizedBox(height: 12),
            ProfileSettingsCard(user: user),
            const SizedBox(height: 12),
            ProfileWeightCard(user: user),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  String get _goalEmoji => switch (user.goal) {
        Goal.lose => '🔥',
        Goal.maintain => '⚖️',
        Goal.bulk => '💪',
      };

  String get _goalLabel => switch (user.goal) {
        Goal.lose => '체중 감량',
        Goal.maintain => '체중 유지',
        Goal.bulk => '벌크업',
      };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(_goalEmoji, style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    _goalLabel,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('·',
                      style: GoogleFonts.notoSansKr(
                          fontSize: 11, color: colors.textGrey)),
                  const SizedBox(width: 8),
                  Text(
                    user.email,
                    style: GoogleFonts.notoSansKr(
                        fontSize: 11, color: colors.textGrey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyStatsRow extends StatelessWidget {
  const _BodyStatsRow({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bmiColor = switch (user.bmiLabel) {
      '정상' => colors.primary,
      '저체중' => Colors.blueAccent,
      '과체중' => Colors.orangeAccent,
      _ => Colors.redAccent,
    };

    return Column(
      children: [
        Row(
          children: [
            _StatChip(label: '키', value: '${user.height.toStringAsFixed(0)}cm'),
            const SizedBox(width: 8),
            _StatChip(
                label: '몸무게', value: '${user.weight.toStringAsFixed(1)}kg'),
            const SizedBox(width: 8),
            _StatChip(label: '나이', value: '${user.age}세'),
            const SizedBox(width: 8),
            _StatChip(
                label: '성별',
                value: user.gender == Gender.male ? '남성' : '여성'),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.inputBorder),
          ),
          child: Row(
            children: [
              Text('BMI',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 11, color: colors.textGrey)),
              const SizedBox(width: 10),
              Text(
                user.bmi.toStringAsFixed(1),
                style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: bmiColor),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bmiColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.bmiLabel,
                  style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: bmiColor),
                ),
              ),
              const Spacer(),
              Text('18.5–22.9 정상범위',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 10, color: colors.textGrey)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.inputBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                  fontSize: 9, color: colors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieGoalCard extends StatelessWidget {
  const _CalorieGoalCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '하루 목표 칼로리',
            style:
                GoogleFonts.notoSansKr(fontSize: 11, color: colors.textGrey),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.dailyCalorieGoal.toStringAsFixed(0),
                style: GoogleFonts.notoSansKr(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'kcal',
                  style: GoogleFonts.notoSansKr(
                      fontSize: 12, color: colors.textGrey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

