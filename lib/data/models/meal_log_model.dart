import 'food_item_model.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExtension on MealType {
  String get label => switch (this) {
        MealType.breakfast => '아침',
        MealType.lunch => '점심',
        MealType.dinner => '저녁',
        MealType.snack => '간식',
      };

  String get emoji => switch (this) {
        MealType.breakfast => '🌅',
        MealType.lunch => '☀️',
        MealType.dinner => '🌙',
        MealType.snack => '🍎',
      };

  String get dbValue => name;

  static MealType fromDb(String value) =>
      MealType.values.firstWhere((e) => e.name == value);
}

class MealLogModel {
  const MealLogModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foods,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String userId;
  final DateTime date;
  final MealType mealType;
  final List<FoodItemModel> foods;
  final String? note;
  final DateTime createdAt;

  double get totalCalories =>
      foods.fold(0, (sum, f) => sum + f.calories);
  double get totalProtein =>
      foods.fold(0, (sum, f) => sum + f.protein);
  double get totalCarbs =>
      foods.fold(0, (sum, f) => sum + f.carbs);
  double get totalFat =>
      foods.fold(0, (sum, f) => sum + f.fat);

  MealLogModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MealType? mealType,
    List<FoodItemModel>? foods,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
  }) {
    return MealLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foods: foods ?? this.foods,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
