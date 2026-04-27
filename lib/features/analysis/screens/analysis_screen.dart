import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../../meal_log/providers/meal_log_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key, required this.dateStr});

  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final user = ref.watch(authProvider).user;
    if (user == null) return const Scaffold();

    final nutrition = ref.watch(dailyNutritionProvider(date));
    final logsAsync = ref.watch(mealLogsForDateProvider(date));
    final calGoal = user.dailyCalorieGoal;

    final remaining =
        (calGoal - nutrition.calories).clamp(0.0, double.infinity);
    final achievement = calGoal > 0
        ? ((nutrition.calories / calGoal) * 100).clamp(0.0, 999.0)
        : 0.0;

    final feedback = _generateFeedback(
      calories: nutrition.calories,
      calGoal: calGoal,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          '오늘의 식단 분석',
          style: GoogleFonts.notoSansKr(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    '총 섭취 칼로리',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${nutrition.calories.toStringAsFixed(0)} kcal',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatItem(
                        label: '권장 섭취',
                        value: calGoal.toStringAsFixed(0),
                        unit: 'kcal',
                      ),
                      const VerticalDivider(
                          color: Colors.white38, width: 1, thickness: 0.5),
                      _StatItem(
                        label: '남은 칼로리',
                        value: remaining.toStringAsFixed(0),
                        unit: 'kcal',
                      ),
                      const VerticalDivider(
                          color: Colors.white38, width: 1, thickness: 0.5),
                      _StatItem(
                        label: '달성률',
                        value: achievement.toStringAsFixed(1),
                        unit: '%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 한마디',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      color: colors.textDark,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '오늘의 식사 내역',
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            logsAsync.when(
              data: (logs) {
                final allFoods = logs.expand((l) => l.foods).toList();
                if (allFoods.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        '기록된 식사가 없습니다.',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          color: colors.textGrey,
                        ),
                      ),
                    ),
                  );
                }
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allFoods.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 0.5,
                      color: colors.border,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final food = allFoods[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          food.name,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.textDark,
                          ),
                        ),
                        subtitle: Text(
                          '${food.amount.toStringAsFixed(0)}${food.unit}',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 11,
                            color: colors.textGrey,
                          ),
                        ),
                        trailing: Text(
                          '${food.calories.toStringAsFixed(0)} kcal',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  String _generateFeedback({
    required double calories,
    required double calGoal,
  }) {
    if (calories == 0) return '오늘 아직 기록된 식사가 없어요. 식사를 기록해 영양 분석을 받아보세요! 🥗';

    final calorieRatio = calGoal > 0 ? calories / calGoal : 0.0;

    if (calorieRatio > 1.2) {
      return '오늘 권장 칼로리를 ${((calorieRatio - 1) * 100).toStringAsFixed(0)}% 초과했어요. '
          '내일은 가벼운 식단으로 균형을 맞춰보는 건 어떨까요? 💪';
    } else if (calorieRatio < 0.6) {
      return '오늘 섭취량이 권장량의 ${(calorieRatio * 100).toStringAsFixed(0)}%에 불과해요. '
          '충분한 영양 섭취가 건강 유지에 중요해요! 🍽️';
    } else {
      return '오늘 권장 칼로리에 맞춰 적절하게 식사하셨네요! 꾸준한 식습관 관리가 건강의 첫걸음이에요. 훌륭해요! ✨';
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.notoSansKr(
              fontSize: 7,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
