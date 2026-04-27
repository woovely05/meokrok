import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import 'package:drift/drift.dart' show Value;
import '../../../data/database/app_database.dart';
import '../../meal_log/providers/meal_log_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final user = ref.watch(authProvider).user;
    if (user == null) return const Scaffold();

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
            _SettingsCard(user: user),
            const SizedBox(height: 12),
            _WeightCard(user: user),
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
            style: GoogleFonts.notoSansKr(
                fontSize: 11, color: colors.textGrey),
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

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        children: [
          _SettingsTile(
            label: '신체 정보 수정',
            onTap: () => _showEditModal(context, ref),
          ),
          Divider(
              height: 0.5,
              thickness: 0.5,
              color: colors.border,
              indent: 16,
              endIndent: 16),
          _SettingsTile(
            label: '목표 변경',
            onTap: () => _showGoalModal(context, ref),
          ),
          Divider(
              height: 0.5,
              thickness: 0.5,
              color: colors.border,
              indent: 16,
              endIndent: 16),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  '다크 모드',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.textDark,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: isDark,
                  activeColor: colors.primary,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),
              ],
            ),
          ),
          Divider(
              height: 0.5,
              thickness: 0.5,
              color: colors.border,
              indent: 16,
              endIndent: 16),
          _SettingsTile(
            label: '로그아웃',
            textColor: Colors.redAccent,
            showChevron: false,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final heightCtrl =
        TextEditingController(text: user.height.toStringAsFixed(0));
    final weightCtrl =
        TextEditingController(text: user.weight.toStringAsFixed(1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '신체 정보 수정',
              style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textDark),
            ),
            const SizedBox(height: 16),
            _EditField(label: '키 (cm)', controller: heightCtrl),
            const SizedBox(height: 10),
            _EditField(label: '몸무게 (kg)', controller: weightCtrl),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: '저장하기',
              onPressed: () {
                final h = double.tryParse(heightCtrl.text);
                final w = double.tryParse(weightCtrl.text);
                if (h != null && w != null) {
                  ref
                      .read(authProvider.notifier)
                      .saveProfile(user.copyWith(height: h, weight: w));
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalModal(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    Goal selected = user.goal;

    const goals = [
      (Goal.lose, '체중 감량', '🔥', '칼로리 20% 적자'),
      (Goal.maintain, '체중 유지', '⚖️', '유지 칼로리'),
      (Goal.bulk, '벌크업', '💪', '칼로리 15% 잉여'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '목표 변경',
                style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textDark),
              ),
              const SizedBox(height: 16),
              ...goals.map((g) {
                final isSelected = selected == g.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => selected = g.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primaryLight
                            : colors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.inputBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(g.$3,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.$2,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? colors.primary
                                      : colors.textDark,
                                ),
                              ),
                              Text(
                                g.$4,
                                style: GoogleFonts.notoSansKr(
                                    fontSize: 10, color: colors.textGrey),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle,
                                size: 18, color: colors.primary),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              AppPrimaryButton(
                label: '저장하기',
                onPressed: () {
                  ref
                      .read(authProvider.notifier)
                      .saveProfile(user.copyWith(goal: selected));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    required this.onTap,
    this.textColor,
    this.showChevron = true,
  });

  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor ?? colors.textDark,
              ),
            ),
            const Spacer(),
            if (showChevron)
              Icon(Icons.chevron_right, size: 16, color: colors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansKr(
              fontSize: 10, color: colors.textGrey),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.notoSansKr(
                fontSize: 14, color: colors.textDark),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightCard extends ConsumerWidget {
  const _WeightCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final entries = ref.watch(weightLogsProvider).valueOrNull ?? [];
    final latest = entries.isNotEmpty ? entries.last : null;
    final prev = entries.length >= 2 ? entries[entries.length - 2] : null;
    final diff = (latest != null && prev != null)
        ? latest.weight - prev.weight
        : null;

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
          Row(
            children: [
              Text(
                '체중 기록',
                style: GoogleFonts.notoSansKr(
                    fontSize: 11, color: colors.textGrey),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddWeightModal(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.inputBorder),
                  ),
                  child: Text(
                    '+ 기록',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${latest.weight.toStringAsFixed(1)}kg',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                    height: 1,
                  ),
                ),
                if (diff != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      diff >= 0
                          ? '+${diff.toStringAsFixed(1)}kg'
                          : '${diff.toStringAsFixed(1)}kg',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12,
                        color: diff > 0
                            ? Colors.orangeAccent
                            : colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '+ 기록을 눌러 오늘 체중을 추가하세요',
                style: GoogleFonts.notoSansKr(
                    fontSize: 11, color: colors.textGrey),
              ),
            ),
          if (entries.length >= 2) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 80,
              child: LineChart(
                LineChartData(
                  minY: entries
                          .map((e) => e.weight)
                          .reduce((a, b) => a < b ? a : b) -
                      1,
                  maxY: entries
                          .map((e) => e.weight)
                          .reduce((a, b) => a > b ? a : b) +
                      1,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: entries
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.weight))
                          .toList(),
                      isCurved: true,
                      color: colors.primary,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, __, ___) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: colors.surface,
                          strokeWidth: 2,
                          strokeColor: colors.primary,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddWeightModal(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final ctrl =
        TextEditingController(text: user.weight.toStringAsFixed(1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘 체중 기록',
              style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textDark),
            ),
            const SizedBox(height: 16),
            _EditField(label: '체중 (kg)', controller: ctrl),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: '저장하기',
              onPressed: () async {
                final w = double.tryParse(ctrl.text);
                if (w == null) return;
                final db = ref.read(appDatabaseProvider);
                final today = DateTime.now();
                final date =
                    DateTime(today.year, today.month, today.day);
                await db.upsertWeightLog(WeightLogsTableCompanion(
                  id: Value(const Uuid().v4()),
                  userId: Value(user.id),
                  date: Value(date),
                  weight: Value(w),
                ));
                ref.invalidate(weightLogsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
