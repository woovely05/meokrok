import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import 'profile_edit_field.dart';

class ProfileSettingsCard extends ConsumerWidget {
  const ProfileSettingsCard({super.key, required this.user});

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
          ProfileSettingsTile(
            label: '신체 정보 수정',
            onTap: () => _showEditModal(context, ref),
          ),
          Divider(
              height: 0.5,
              thickness: 0.5,
              color: colors.border,
              indent: 16,
              endIndent: 16),
          ProfileSettingsTile(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          ProfileSettingsTile(
            label: '로그아웃',
            textColor: Colors.redAccent,
            showChevron: false,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: colors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  title: Text(
                    '로그아웃',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textDark),
                  ),
                  content: Text(
                    '정말 로그아웃 하시겠어요?',
                    style: GoogleFonts.notoSansKr(
                        fontSize: 13, color: colors.textGrey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('취소',
                          style:
                              GoogleFonts.notoSansKr(color: colors.textGrey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('로그아웃',
                          style: GoogleFonts.notoSansKr(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
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
            ProfileEditField(label: '키 (cm)', controller: heightCtrl),
            const SizedBox(height: 10),
            ProfileEditField(label: '몸무게 (kg)', controller: weightCtrl),
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
                        color:
                            isSelected ? colors.primaryLight : colors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.inputBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(g.$3, style: const TextStyle(fontSize: 18)),
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

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
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
