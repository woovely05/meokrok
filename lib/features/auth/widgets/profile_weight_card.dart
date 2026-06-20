import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/user_model.dart';
import '../../meal_log/providers/meal_log_provider.dart';
import '../providers/auth_provider.dart';
import 'profile_edit_field.dart';

class ProfileWeightCard extends ConsumerWidget {
  const ProfileWeightCard({super.key, required this.user});

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
                style:
                    GoogleFonts.notoSansKr(fontSize: 11, color: colors.textGrey),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddWeightModal(context, ref),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        color:
                            diff > 0 ? Colors.orangeAccent : colors.primary,
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
    final ctrl = TextEditingController(text: user.weight.toStringAsFixed(1));

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
            ProfileEditField(label: '체중 (kg)', controller: ctrl),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: '저장하기',
              onPressed: () async {
                final w = double.tryParse(ctrl.text);
                if (w == null) return;
                final db = ref.read(appDatabaseProvider);
                final today = DateTime.now();
                final date = DateTime(today.year, today.month, today.day);
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
