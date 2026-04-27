import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/meal_log_model.dart';
import '../models/food_item_model.dart';

class MealRepository {
  const MealRepository(this._db);

  final AppDatabase _db;

  Future<List<MealLogModel>> getLogsForDate(String userId, DateTime date) async {
    final rows = await _db.getMealLogsByDate(userId, date);
    return rows.map(_toModel).toList();
  }

  Future<List<DateTime>> getDatesWithLogs(
      String userId, int year, int month) =>
      _db.getDatesWithLogs(userId, year, month);

  Future<List<DateTime>> getAllDatesWithLogs(String userId) =>
      _db.getAllDatesWithLogs(userId);

  Future<void> saveMealLog(MealLogModel log) async {
    await _db.upsertMealLog(MealLogsTableCompanion(
      id: Value(log.id),
      userId: Value(log.userId),
      date: Value(log.date),
      mealType: Value(log.mealType.name),
      foodsJson: Value(log.foods),
      note: Value(log.note),
      createdAt: Value(log.createdAt),
    ));
  }

  Future<MealLogModel> createEmptyLog({
    required String userId,
    required DateTime date,
    required MealType mealType,
  }) async {
    final id = const Uuid().v4();
    final log = MealLogModel(
      id: id,
      userId: userId,
      date: date,
      mealType: mealType,
      foods: [],
      createdAt: DateTime.now(),
    );
    await saveMealLog(log);
    return log;
  }

  Future<Map<String, double>> getCaloriesByMonth(
      String userId, int year, int month) async {
    final rows = await _db.getMealLogsByMonth(userId, year, month);
    final result = <String, double>{};
    for (final row in rows) {
      final d = row.date;
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final cals =
          row.foodsJson.fold<double>(0, (s, f) => s + f.calories);
      result[key] = (result[key] ?? 0) + cals;
    }
    return result;
  }

  Future<void> deleteLog(String id) => _db.deleteMealLog(id);

  MealLogModel _toModel(MealLogRow row) => MealLogModel(
        id: row.id,
        userId: row.userId,
        date: row.date,
        mealType: MealType.values.firstWhere((t) => t.name == row.mealType),
        foods: row.foodsJson,
        note: row.note,
        createdAt: row.createdAt,
      );
}

class BuiltinFoodDatabase {
  static const _foods = [
    {'name': '흰쌀밥', 'calPer100': 130.0, 'protein': 2.5, 'carbs': 28.2, 'fat': 0.3},
    {'name': '현미밥', 'calPer100': 111.0, 'protein': 2.6, 'carbs': 23.5, 'fat': 0.9},
    {'name': '라면', 'calPer100': 462.0, 'protein': 10.2, 'carbs': 64.5, 'fat': 17.2},
    {'name': '닭가슴살', 'calPer100': 109.0, 'protein': 23.0, 'carbs': 0.0, 'fat': 1.2},
    {'name': '삼겹살', 'calPer100': 330.0, 'protein': 17.0, 'carbs': 0.0, 'fat': 28.0},
    {'name': '계란', 'calPer100': 155.0, 'protein': 13.0, 'carbs': 1.1, 'fat': 11.0},
    {'name': '우유', 'calPer100': 61.0, 'protein': 3.2, 'carbs': 4.8, 'fat': 3.3},
    {'name': '토스트', 'calPer100': 290.0, 'protein': 9.0, 'carbs': 50.0, 'fat': 5.5},
    {'name': '바나나', 'calPer100': 89.0, 'protein': 1.1, 'carbs': 23.0, 'fat': 0.3},
    {'name': '사과', 'calPer100': 52.0, 'protein': 0.3, 'carbs': 14.0, 'fat': 0.2},
    {'name': '김치', 'calPer100': 18.0, 'protein': 1.5, 'carbs': 3.6, 'fat': 0.5},
    {'name': '두부', 'calPer100': 76.0, 'protein': 8.0, 'carbs': 1.9, 'fat': 4.2},
    {'name': '된장찌개', 'calPer100': 55.0, 'protein': 4.0, 'carbs': 5.0, 'fat': 2.0},
    {'name': '비빔밥', 'calPer100': 155.0, 'protein': 5.0, 'carbs': 28.0, 'fat': 3.0},
    {'name': '김밥', 'calPer100': 170.0, 'protein': 5.5, 'carbs': 30.0, 'fat': 3.5},
  ];

  static FoodItemModel? findFood(String name, double amount, String unit) {
    final food = _foods.cast<Map<String, dynamic>?>().firstWhere(
          (f) => f!['name']
              .toString()
              .toLowerCase()
              .contains(name.toLowerCase()),
          orElse: () => null,
        );
    if (food == null) return null;

    final ratio = amount / 100.0;
    return FoodItemModel(
      id: const Uuid().v4(),
      name: food['name'] as String,
      amount: amount,
      unit: unit,
      calories: (food['calPer100'] as double) * ratio,
      protein: (food['protein'] as double) * ratio,
      carbs: (food['carbs'] as double) * ratio,
      fat: (food['fat'] as double) * ratio,
    );
  }

  static FoodItemModel createManual(
      String name, double amount, String unit, double caloriesPer100) {
    final ratio = amount / 100.0;
    final totalCals = caloriesPer100 * ratio;

    final estimatedCarbs = (totalCals * 0.4) / 4;
    final estimatedProtein = (totalCals * 0.3) / 4;
    final estimatedFat = (totalCals * 0.3) / 9;

    return FoodItemModel(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      unit: unit,
      calories: totalCals,
      protein: estimatedProtein,
      carbs: estimatedCarbs,
      fat: estimatedFat,
    );
  }
}
