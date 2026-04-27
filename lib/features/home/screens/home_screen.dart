import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../../meal_log/providers/meal_log_provider.dart';
import '../../../data/models/meal_log_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final user = ref.watch(authProvider).user;
    final selectedDate = ref.watch(selectedDateProvider);
    final ym = (selectedDate.year, selectedDate.month);
    final datesAsync = ref.watch(datesWithLogsProvider(ym));
    final calMap =
        ref.watch(monthCaloriesProvider(ym)).valueOrNull ?? <String, double>{};
    final nutrition = ref.watch(dailyNutritionProvider(selectedDate));

    final streak = ref.watch(streakProvider).valueOrNull ?? 0;
    final weeklyData = ref.watch(weeklyCaloriesProvider).valueOrNull ?? [];
    final waterCount = ref.watch(waterProvider(selectedDate));
    final calGoal = user?.dailyCalorieGoal ?? 2000;
    final achievement = calGoal > 0
        ? ((nutrition.calories / calGoal) * 100).clamp(0.0, 999.0)
        : 0.0;

    final feedback = _generateSimpleFeedback(
      calories: nutrition.calories,
      calGoal: calGoal,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('🥗', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '먹록',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.inputBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            '$streak일 연속',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: datesAsync.when(
                        data: (dates) => _Calendar(
                          selectedDate: selectedDate,
                          datesWithLogs: dates,
                          calMap: calMap,
                          calGoal: calGoal,
                          onSelected: (d) =>
                              ref.read(selectedDateProvider.notifier).state = d,
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (weeklyData.isNotEmpty)
                      _WeeklyChart(data: weeklyData, calGoal: calGoal),
                    if (weeklyData.isNotEmpty) const SizedBox(height: 12),
                    AppPrimaryButton(
                      label: '+ 오늘 식사 기록하기',
                      onPressed: () {
                        final d =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                        context.push('/meal-log/$d');
                      },
                    ),
                    const SizedBox(height: 12),
                    _WaterTracker(
                        count: waterCount, ref: ref, date: selectedDate),
                    const SizedBox(height: 12),
                    if (user != null)
                      _ReportCard(
                          userId: user.id, calGoal: calGoal.toDouble()),
                    if (user != null) const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '오늘의 분석 요약',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final d = DateFormat('yyyy-MM-dd')
                                      .format(selectedDate);
                                  context.push('/analysis/$d');
                                },
                                child: Text(
                                  '상세분석 >',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 10,
                                    color: colors.textGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${achievement.toStringAsFixed(1)}%',
                                      style: GoogleFonts.notoSansKr(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: colors.primary,
                                      ),
                                    ),
                                    Text(
                                      '목표 칼로리 달성 중',
                                      style: GoogleFonts.notoSansKr(
                                        fontSize: 10,
                                        color: colors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 7,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    feedback,
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 11,
                                      color: colors.textDark,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _NutritionBar(
                            label: '칼로리',
                            value: nutrition.calories,
                            goal: calGoal,
                            unit: 'kcal',
                            color: AppColors.calorieBar,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  String _generateSimpleFeedback({
    required double calories,
    required double calGoal,
  }) {
    if (calories == 0) return '식사를 기록하면\n분석 결과를 알려드려요! 🥗';
    final ratio = calGoal > 0 ? calories / calGoal : 0.0;
    if (ratio > 1.2) return '오늘은 평소보다\n든든하게 드셨네요! 💪';
    if (ratio < 0.6) return '조금 더 챙겨 드셔도\n좋을 것 같아요! 🍽️';
    return '아주 적절한 식습관을\n유지하고 계시네요! ✨';
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.selectedDate,
    required this.datesWithLogs,
    required this.calMap,
    required this.calGoal,
    required this.onSelected,
  });

  final DateTime selectedDate;
  final List<DateTime> datesWithLogs;
  final Map<String, double> calMap;
  final double calGoal;
  final ValueChanged<DateTime> onSelected;

  Color? _dayColor(DateTime day, AppColors colors) {
    final key =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final cal = calMap[key];
    if (cal == null) return null;
    if (cal >= calGoal * 0.8 && cal <= calGoal * 1.2) {
      return colors.primary.withValues(alpha: 0.15);
    }
    if (cal > calGoal * 1.2) {
      return Colors.orangeAccent.withValues(alpha: 0.2);
    }
    return Colors.blueAccent.withValues(alpha: 0.12);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: selectedDate,
      selectedDayPredicate: (d) => isSameDay(d, selectedDate),
      onDaySelected: (selected, _) => onSelected(selected),
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.textDark,
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, size: 18),
        rightChevronIcon: const Icon(Icons.chevron_right, size: 18),
        headerPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle:
            GoogleFonts.notoSansKr(fontSize: 9, color: colors.textGrey),
        weekendStyle:
            GoogleFonts.notoSansKr(fontSize: 9, color: colors.textGrey),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle:
            GoogleFonts.notoSansKr(fontSize: 10, color: colors.textDark),
        weekendTextStyle:
            GoogleFonts.notoSansKr(fontSize: 10, color: colors.textDark),
        selectedDecoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: GoogleFonts.notoSansKr(
            fontSize: 10, color: AppColors.white),
        todayDecoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        todayTextStyle:
            GoogleFonts.notoSansKr(fontSize: 10, color: colors.primary),
        outsideDaysVisible: false,
        markerDecoration: BoxDecoration(
          color: colors.primaryLight,
          shape: BoxShape.circle,
        ),
      ),
      eventLoader: (day) => datesWithLogs.any(
              (d) =>
                  d.year == day.year &&
                  d.month == day.month &&
                  d.day == day.day)
          ? [1]
          : [],
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (ctx, day, _) {
          final color = _dayColor(day, colors);
          if (color == null) return null;
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${day.day}',
                style: GoogleFonts.notoSansKr(
                    fontSize: 10, color: colors.textDark),
              ),
            ),
          );
        },
      ),
      rowHeight: 36,
    );
  }
}

class _NutritionBar extends StatelessWidget {
  const _NutritionBar({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final ratio = (goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0);
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colors.textDark,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: colors.primaryLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            '${value.toStringAsFixed(0)}/${goal.toStringAsFixed(0)}$unit',
            style: GoogleFonts.notoSansKr(fontSize: 10, color: colors.textGrey),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _WaterTracker extends StatelessWidget {
  const _WaterTracker({
    required this.count,
    required this.ref,
    required this.date,
  });

  final int count;
  final WidgetRef ref;
  final DateTime date;

  static const _goal = 8;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '물 섭취',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11,
                        color: colors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(_goal, (i) {
                        final filled = i < count;
                        return Container(
                          margin: const EdgeInsets.only(right: 3),
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: filled ? colors.primary : colors.primaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: filled
                                  ? colors.primary
                                  : colors.inputBorder,
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                ref.read(waterProvider(date).notifier).decrement(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.inputBorder),
              ),
              child: Icon(Icons.remove, size: 16, color: colors.textGrey),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count / $_goal',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: count >= _goal ? colors.primary : colors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () =>
                ref.read(waterProvider(date).notifier).increment(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.inputBorder),
              ),
              child: Icon(Icons.add, size: 16, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data, required this.calGoal});

  final List<({DateTime date, double calories})> data;
  final double calGoal;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxY = ([calGoal, ...data.map((d) => d.calories)]
            .reduce((a, b) => a > b ? a : b) *
        1.2);
    final today = DateTime.now();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 7일 칼로리',
            style:
                GoogleFonts.notoSansKr(fontSize: 11, color: colors.textGrey),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: calGoal,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colors.primary.withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final d = data[i].date;
                        final isToday = d.year == today.year &&
                            d.month == today.month &&
                            d.day == today.day;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            isToday ? '오늘' : '${d.month}/${d.day}',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 9,
                              color: isToday
                                  ? colors.primary
                                  : colors.textGrey,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      reservedSize: 20,
                    ),
                  ),
                ),
                barGroups: data.asMap().entries.map((e) {
                  final i = e.key;
                  final cal = e.value.calories;
                  final isToday = e.value.date.year == today.year &&
                      e.value.date.month == today.month &&
                      e.value.date.day == today.day;
                  final overGoal = cal > calGoal;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: cal == 0 ? 0.0 : cal,
                        color: cal == 0
                            ? colors.border
                            : overGoal
                                ? Colors.orangeAccent
                                : isToday
                                    ? colors.primary
                                    : AppColors.proteinBar,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: colors.primaryLight,
                        ),
                      ),
                    ],
                  );
                }).toList(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.textDark,
                    tooltipRoundedRadius: 6,
                    getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                      '${rod.toY.toStringAsFixed(0)} kcal',
                      GoogleFonts.notoSansKr(
                          fontSize: 10, color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends ConsumerStatefulWidget {
  const _ReportCard({required this.userId, required this.calGoal});

  final String userId;
  final double calGoal;

  @override
  ConsumerState<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<_ReportCard> {
  bool _isWeekly = true;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final days = _isWeekly ? 7 : 30;
    final reportAsync =
        ref.watch(periodReportProvider((widget.userId, widget.calGoal, days)));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '기간 리포트',
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _PeriodTab(
                      label: '이번 주',
                      selected: _isWeekly,
                      onTap: () => setState(() => _isWeekly = true),
                    ),
                    _PeriodTab(
                      label: '이번 달',
                      selected: !_isWeekly,
                      onTap: () => setState(() => _isWeekly = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          reportAsync.when(
            data: (r) => _ReportBody(report: r, colors: colors),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSansKr(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : colors.textGrey,
          ),
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.colors});

  final PeriodReport report;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    if (report.recordedDays == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '아직 기록된 식사가 없어요.',
          style: GoogleFonts.notoSansKr(fontSize: 12, color: colors.textGrey),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            _ReportStat(
              label: '기록일',
              value: '${report.recordedDays}/${report.totalDays}일',
              colors: colors,
            ),
            _ReportStat(
              label: '평균 칼로리',
              value: '${report.avgCalories.toStringAsFixed(0)} kcal',
              colors: colors,
            ),
            _ReportStat(
              label: '목표 달성',
              value: '${report.goalAchievedDays}일',
              colors: colors,
            ),
          ],
        ),
        if (report.topMealType != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: colors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(report.topMealType!.emoji,
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  '${report.topMealType!.label}을 가장 많이 기록했어요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 11,
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                GoogleFonts.notoSansKr(fontSize: 9, color: colors.textGrey),
          ),
        ],
      ),
    );
  }
}
