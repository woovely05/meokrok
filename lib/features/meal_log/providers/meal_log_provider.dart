import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/food_item_model.dart';
import '../../../data/models/meal_log_model.dart';
import '../../../data/repositories/meal_repository.dart';
import '../../auth/providers/auth_provider.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(ref.watch(appDatabaseProvider));
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final mealLogsForDateProvider =
    FutureProvider.family<List<MealLogModel>, DateTime>((ref, date) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  final repo = ref.watch(mealRepositoryProvider);
  final d = DateTime(date.year, date.month, date.day);
  return repo.getLogsForDate(user.id, d);
});

final datesWithLogsProvider =
    FutureProvider.family<List<DateTime>, (int, int)>((ref, ym) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getDatesWithLogs(user.id, ym.$1, ym.$2);
});

final monthCaloriesProvider =
    FutureProvider.autoDispose.family<Map<String, double>, (int, int)>((ref, ym) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return {};
  final repo = ref.watch(mealRepositoryProvider);
  return repo.getCaloriesByMonth(user.id, ym.$1, ym.$2);
});

class DailyNutrition {
  const DailyNutrition({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}

final dailyNutritionProvider =
    Provider.family<DailyNutrition, DateTime>((ref, date) {
  final logs = ref.watch(mealLogsForDateProvider(date));
  return logs.when(
    data: (list) => DailyNutrition(
      calories: list.fold(0, (s, l) => s + l.totalCalories),
      protein: list.fold(0, (s, l) => s + l.totalProtein),
      carbs: list.fold(0, (s, l) => s + l.totalCarbs),
      fat: list.fold(0, (s, l) => s + l.totalFat),
    ),
    loading: () => const DailyNutrition(),
    error: (_, _) => const DailyNutrition(),
  );
});

class WaterNotifier extends StateNotifier<int> {
  WaterNotifier(this._date) : super(0) {
    _load();
  }

  final DateTime _date;

  String get _key =>
      'water_${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_key) ?? 0;
  }

  Future<void> increment() async {
    state = state + 1;
    await _save();
  }

  Future<void> decrement() async {
    if (state <= 0) return;
    state = state - 1;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, state);
  }
}

final waterProvider = StateNotifierProvider.autoDispose
    .family<WaterNotifier, int, DateTime>(
      (ref, date) => WaterNotifier(date),
    );

class WeightEntry {
  const WeightEntry({required this.date, required this.weight});
  final DateTime date;
  final double weight;
}

final weightLogsProvider = FutureProvider<List<WeightEntry>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.getWeightLogs(user.id);
  return rows
      .map((r) => WeightEntry(date: r.date, weight: r.weight))
      .toList();
});

final weeklyCaloriesProvider =
    FutureProvider.autoDispose<List<({DateTime date, double calories})>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  final repo = ref.watch(mealRepositoryProvider);
  final today = DateTime.now();
  final result = <({DateTime date, double calories})>[];
  for (int i = 6; i >= 0; i--) {
    final d = today.subtract(Duration(days: i));
    final date = DateTime(d.year, d.month, d.day);
    final logs = await repo.getLogsForDate(user.id, date);
    final cal = logs.fold<double>(0, (s, l) => s + l.totalCalories);
    result.add((date: date, calories: cal));
  }
  return result;
});

final recentFoodsProvider = FutureProvider.autoDispose<List<FoodItemModel>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  final repo = ref.watch(mealRepositoryProvider);
  final dates = await repo.getAllDatesWithLogs(user.id);
  final recent = dates.take(14).toList();
  final seen = <String>{};
  final result = <FoodItemModel>[];
  for (final date in recent) {
    final logs = await repo.getLogsForDate(user.id, date);
    for (final log in logs) {
      for (final food in log.foods.reversed) {
        if (seen.add(food.name) && result.length < 5) {
          result.add(food);
        }
      }
    }
    if (result.length >= 5) break;
  }
  return result;
});

final streakProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return 0;
  final repo = ref.watch(mealRepositoryProvider);
  final dates = await repo.getAllDatesWithLogs(user.id);
  final dateSet = dates.toSet();
  final today = DateTime.now();
  var check = DateTime(today.year, today.month, today.day);
  int streak = 0;
  while (dateSet.contains(check)) {
    streak++;
    check = check.subtract(const Duration(days: 1));
  }
  return streak;
});

class MealEditorState {
  const MealEditorState({required this.logs});

  final Map<MealType, MealLogModel?> logs;

  MealEditorState withLog(MealType type, MealLogModel log) => MealEditorState(
        logs: {...logs, type: log},
      );

  List<MealLogModel> get allLogs =>
      logs.values.whereType<MealLogModel>().toList();
}

class MealEditorNotifier extends StateNotifier<MealEditorState> {
  MealEditorNotifier(this._repo, this._ref, this._userId, this._date)
      : super(const MealEditorState(logs: {})) {
    _load();
  }

  final MealRepository _repo;
  final Ref _ref;
  final String _userId;
  final DateTime _date;

  Future<void> _load() async {
    final existing = await _repo.getLogsForDate(_userId, _date);
    final map = <MealType, MealLogModel?>{
      for (final t in MealType.values)
        t: existing.cast<MealLogModel?>().firstWhere(
              (l) => l?.mealType == t,
              orElse: () => null,
            ),
    };
    state = MealEditorState(logs: map);
  }

  Future<void> addFood(MealType type, FoodItemModel food) async {
    final existing = state.logs[type];
    final MealLogModel log;
    if (existing == null) {
      log = await _repo.createEmptyLog(
        userId: _userId,
        date: _date,
        mealType: type,
      );
    } else {
      log = existing;
    }
    final updated = log.copyWith(foods: [...log.foods, food]);
    await _repo.saveMealLog(updated);
    state = state.withLog(type, updated);
    _invalidateDependents();
  }

  Future<void> removeFood(MealType type, String foodId) async {
    final log = state.logs[type];
    if (log == null) return;
    final updated = log.copyWith(
      foods: log.foods.where((f) => f.id != foodId).toList(),
    );
    await _repo.saveMealLog(updated);
    state = state.withLog(type, updated);
    _invalidateDependents();
  }

  Future<void> copyFromDate(MealType type, DateTime fromDate) async {
    final logs = await _repo.getLogsForDate(_userId, fromDate);
    final srcLog = logs.cast<MealLogModel?>().firstWhere(
      (l) => l?.mealType == type,
      orElse: () => null,
    );
    if (srcLog == null || srcLog.foods.isEmpty) return;

    final existing = state.logs[type];
    final MealLogModel targetLog;
    if (existing == null) {
      targetLog = await _repo.createEmptyLog(
          userId: _userId, date: _date, mealType: type);
    } else {
      targetLog = existing;
    }

    final newFoods = srcLog.foods
        .map((f) => FoodItemModel(
              id: const Uuid().v4(),
              name: f.name,
              amount: f.amount,
              unit: f.unit,
              calories: f.calories,
              protein: f.protein,
              carbs: f.carbs,
              fat: f.fat,
            ))
        .toList();

    final updated =
        targetLog.copyWith(foods: [...targetLog.foods, ...newFoods]);
    await _repo.saveMealLog(updated);
    state = state.withLog(type, updated);
    _invalidateDependents();
  }

  Future<void> saveNote(MealType type, String? note) async {
    var log = state.logs[type] ??
        await _repo.createEmptyLog(
            userId: _userId, date: _date, mealType: type);
    final updated = note == null || note.isEmpty
        ? log.copyWith(clearNote: true)
        : log.copyWith(note: note);
    await _repo.saveMealLog(updated);
    state = state.withLog(type, updated);
  }

  void _invalidateDependents() {
    _ref.invalidate(mealLogsForDateProvider(_date));
    _ref.invalidate(weeklyCaloriesProvider);
    _ref.invalidate(streakProvider);
    _ref.invalidate(recentFoodsProvider);
    _ref.invalidate(monthCaloriesProvider((_date.year, _date.month)));
    _ref.invalidate(datesWithLogsProvider((_date.year, _date.month)));
  }
}

final mealEditorProvider = StateNotifierProvider.autoDispose
    .family<MealEditorNotifier, MealEditorState, (String, DateTime)>(
  (ref, args) => MealEditorNotifier(
    ref.watch(mealRepositoryProvider),
    ref,
    args.$1,
    args.$2,
  ),
);

class PeriodReport {
  const PeriodReport({
    this.avgCalories = 0,
    this.goalAchievedDays = 0,
    this.totalDays = 0,
    this.recordedDays = 0,
    this.topMealType,
  });

  final double avgCalories;
  final int goalAchievedDays;
  final int totalDays;
  final int recordedDays;
  final MealType? topMealType;
}

final periodReportProvider = FutureProvider.autoDispose
    .family<PeriodReport, (String, double, int)>((ref, args) async {
  final (userId, calGoal, days) = args;
  final repo = ref.watch(mealRepositoryProvider);
  final today = DateTime.now();

  double totalCal = 0;
  int goalDays = 0;
  int recordedDays = 0;
  final mealTypeCounts = <MealType, int>{};

  for (int i = 0; i < days; i++) {
    final d = today.subtract(Duration(days: i));
    final date = DateTime(d.year, d.month, d.day);
    final logs = await repo.getLogsForDate(userId, date);
    if (logs.isEmpty) continue;

    final cal = logs.fold<double>(0, (s, l) => s + l.totalCalories);
    if (cal > 0) {
      recordedDays++;
      totalCal += cal;
      if (calGoal > 0 && cal >= calGoal * 0.8 && cal <= calGoal * 1.2) {
        goalDays++;
      }
    }
    for (final log in logs) {
      if (log.foods.isNotEmpty) {
        mealTypeCounts[log.mealType] =
            (mealTypeCounts[log.mealType] ?? 0) + log.foods.length;
      }
    }
  }

  final topMeal = mealTypeCounts.isEmpty
      ? null
      : mealTypeCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  return PeriodReport(
    avgCalories: recordedDays > 0 ? totalCal / recordedDays : 0,
    goalAchievedDays: goalDays,
    totalDays: days,
    recordedDays: recordedDays,
    topMealType: topMeal,
  );
});
