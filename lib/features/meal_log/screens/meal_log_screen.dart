import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/food_item_model.dart';
import '../../../data/models/meal_log_model.dart';
import '../../../data/repositories/meal_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/meal_log_provider.dart';

class MealLogScreen extends ConsumerWidget {
  const MealLogScreen({super.key, required this.dateStr});

  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final user = ref.watch(authProvider).user;
    if (user == null) return const Scaffold();

    final editor = ref.watch(mealEditorProvider((user.id, date)));
    final nutrition = ref.watch(dailyNutritionProvider(date));
    final calGoal = user.dailyCalorieGoal;
    final consumed = nutrition.calories;
    final remaining = calGoal - consumed;
    final ratio = (calGoal > 0 ? (consumed / calGoal).clamp(0.0, 1.0) : 0.0);
    final formattedDate = DateFormat('M월 d일', 'ko_KR').format(date);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '$formattedDate 식사 기록',
          style: GoogleFonts.notoSansKr(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        child: Column(
          children: [
            _CalorieSummaryBar(
              consumed: consumed,
              goal: calGoal,
              remaining: remaining,
              ratio: ratio,
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _MealSection(
                      type: MealType.breakfast,
                      log: editor.logs[MealType.breakfast],
                      date: date,
                      userId: user.id,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MealSection(
                      type: MealType.lunch,
                      log: editor.logs[MealType.lunch],
                      date: date,
                      userId: user.id,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _MealSection(
                      type: MealType.dinner,
                      log: editor.logs[MealType.dinner],
                      date: date,
                      userId: user.id,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MealSection(
                      type: MealType.snack,
                      log: editor.logs[MealType.snack],
                      date: date,
                      userId: user.id,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: AppPrimaryButton(
            label: '분석 완료',
            onPressed: () => context.push('/analysis/$dateStr'),
          ),
        ),
      ),
    );
  }
}

class _MealSection extends ConsumerWidget {
  const _MealSection({
    required this.type,
    required this.log,
    required this.date,
    required this.userId,
  });

  final MealType type;
  final MealLogModel? log;
  final DateTime date;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final foods = log?.foods ?? [];
    final totalCal = log?.totalCalories ?? 0;
    final isEmpty = foods.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isEmpty ? colors.emptySection : colors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: isEmpty
              ? Border.all(color: colors.dashedBorder)
              : Border.all(color: colors.inputBorder, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(type.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    type.label,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (!isEmpty)
                    Text(
                      '${totalCal.toStringAsFixed(0)}\nkcal',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 10,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ),
            if (foods.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: foods.asMap().entries.map((entry) {
                  final i = entry.key;
                  final food = entry.value;
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: colors.border,
                          indent: 12,
                          endIndent: 12,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${food.name} (${food.amount.toStringAsFixed(0)}${food.unit})',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 11,
                                  color: colors.textDark,
                                ),
                              ),
                            ),
                            Text(
                              '${food.calories.toStringAsFixed(0)} kcal',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 11,
                                color: colors.textGrey,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(mealEditorProvider((userId, date))
                                        .notifier)
                                    .removeFood(type, food.id);
                              },
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: colors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showAddFoodModal(context, ref),
                    child: Text(
                      '＋ 음식 추가',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12,
                        color: colors.navInactive,
                      ),
                    ),
                  ),
                  if (isEmpty) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        final yesterday = date.subtract(const Duration(days: 1));
                        ref
                            .read(mealEditorProvider((userId, date)).notifier)
                            .copyFromDate(type, yesterday);
                      },
                      child: Text(
                        '어제 불러오기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final yesterday =
                            date.subtract(const Duration(days: 1));
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: yesterday,
                          firstDate: DateTime(2020),
                          lastDate: yesterday,
                        );
                        if (picked != null) {
                          ref
                              .read(mealEditorProvider((userId, date)).notifier)
                              .copyFromDate(type, picked);
                        }
                      },
                      child: Text(
                        '날짜 선택해서 불러오기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 11,
                          color: colors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (log?.note != null && log!.note!.isNotEmpty)
              GestureDetector(
                onTap: () => _showNoteModal(context, ref),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Row(
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 11, color: colors.textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          log!.note!,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 10,
                            color: colors.textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => _showNoteModal(context, ref),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Text(
                    '메모 추가',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 10,
                      color: colors.navInactive,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNoteModal(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NoteModalSheet(
        title: '${type.emoji} ${type.label} 메모',
        initialNote: log?.note ?? '',
        onSave: (note) {
          ref
              .read(mealEditorProvider((userId, date)).notifier)
              .saveNote(type, note);
        },
      ),
    );
  }

  void _showAddFoodModal(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AddFoodModal(
        onAdd: (food) {
          ref
              .read(mealEditorProvider((userId, date)).notifier)
              .addFood(type, food);
        },
      ),
    );
  }
}

class _AddFoodModal extends ConsumerStatefulWidget {
  const _AddFoodModal({required this.onAdd});

  final ValueChanged<FoodItemModel> onAdd;

  @override
  ConsumerState<_AddFoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends ConsumerState<_AddFoodModal> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '100');
  final _calCtrl = TextEditingController();
  String _unit = 'g';
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text);
    final cal = double.tryParse(_calCtrl.text);

    if (name.isEmpty || amount == null || amount <= 0) {
      setState(() => _error = '음식명과 양을 올바르게 입력해주세요');
      return;
    }

    FoodItemModel food;
    if (cal != null) {
      food = BuiltinFoodDatabase.createManual(name, amount, _unit, cal);
    } else {
      food = BuiltinFoodDatabase.findFood(name, amount, _unit) ??
          BuiltinFoodDatabase.createManual(name, amount, _unit, 0);
    }

    widget.onAdd(food);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '음식 추가',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          ref.watch(recentFoodsProvider).maybeWhen(
            data: (foods) => foods.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '최근 먹은 음식',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 10,
                          color: colors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: foods.map((food) {
                          return GestureDetector(
                            onTap: () {
                              widget.onAdd(FoodItemModel(
                                id: const Uuid().v4(),
                                name: food.name,
                                amount: food.amount,
                                unit: food.unit,
                                calories: food.calories,
                                protein: food.protein,
                                carbs: food.carbs,
                                fat: food.fat,
                              ));
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: colors.inputBorder),
                              ),
                              child: Text(
                                '${food.name} ${food.amount.toStringAsFixed(0)}${food.unit}',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 11,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 0.5, thickness: 0.5, color: colors.border),
                      const SizedBox(height: 14),
                    ],
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          _ModalField(
            controller: _nameCtrl,
            label: '음식명',
            hint: '예: 닭가슴살, 흰쌀밥',
            autofocus: true,
            maxLines: null,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: _ModalField(
                  controller: _amountCtrl,
                  label: '양',
                  keyboardType: TextInputType.number,
                  minLines: 1,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.inputBorder),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: DropdownButton<String>(
                    value: _unit,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: colors.surface,
                    items: ['g', '개', 'ml', '인분']
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(
                              u,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 11,
                                color: colors.textDark,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'g'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ModalField(
            controller: _calCtrl,
            label: '칼로리 (100g 기준, 선택)',
            hint: '예: 150',
            keyboardType: TextInputType.number,
            minLines: 1,
            maxLines: 1,
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 10),
            ),
          ],
          const SizedBox(height: 16),
          AppPrimaryButton(label: '추가', onPressed: _submit),
        ],
      ),
    );
  }
}

class _ModalField extends StatelessWidget {
  const _ModalField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;

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
            fontSize: 12,
            color: colors.textGrey,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: keyboardType,
            minLines: minLines,
            maxLines: maxLines,
            style: GoogleFonts.notoSansKr(fontSize: 14, color: colors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: colors.textGrey,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
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
                horizontal: 12,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalorieSummaryBar extends StatelessWidget {
  const _CalorieSummaryBar({
    required this.consumed,
    required this.goal,
    required this.remaining,
    required this.ratio,
  });

  final double consumed;
  final double goal;
  final double remaining;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isOver = remaining < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CalItem(
                label: '목표',
                value: goal.toStringAsFixed(0),
                color: colors.textGrey,
              ),
              const Spacer(),
              _CalItem(
                label: '섭취',
                value: consumed.toStringAsFixed(0),
                color: colors.primary,
                bold: true,
              ),
              const Spacer(),
              _CalItem(
                label: isOver ? '초과' : '잔여',
                value: remaining.abs().toStringAsFixed(0),
                color: isOver ? Colors.orangeAccent : colors.textDark,
                bold: !isOver,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: colors.primaryLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? Colors.orangeAccent : colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteModalSheet extends StatefulWidget {
  const _NoteModalSheet({
    required this.title,
    required this.initialNote,
    required this.onSave,
  });

  final String title;
  final String initialNote;
  final ValueChanged<String> onSave;

  @override
  State<_NoteModalSheet> createState() => _NoteModalSheetState();
}

class _NoteModalSheetState extends State<_NoteModalSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.textDark),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            style: GoogleFonts.notoSansKr(fontSize: 13, color: colors.textDark),
            decoration: InputDecoration(
              hintText: '식사 메모를 입력하세요',
              hintStyle: GoogleFonts.notoSansKr(
                  fontSize: 12, color: colors.textGrey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            label: '저장',
            onPressed: () {
              widget.onSave(_ctrl.text.trim());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _CalItem extends StatelessWidget {
  const _CalItem({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        Text(
          '$value kcal',
          style: GoogleFonts.notoSansKr(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.notoSansKr(
            fontSize: 9,
            color: colors.textGrey,
          ),
        ),
      ],
    );
  }
}
