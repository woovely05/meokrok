class AppConstants {
  const AppConstants._();

  // Calorie ratio thresholds
  static const double calorieLowRatio = 0.6;
  static const double calorieHighRatio = 1.2;
  static const double calorieGoalMinRatio = 0.8;

  // Macro calorie distribution targets
  static const double proteinCalorieRatio = 0.30;
  static const double carbCalorieRatio = 0.45;
  static const double fatCalorieRatio = 0.25;
  static const double proteinKcalPerGram = 4.0;
  static const double carbKcalPerGram = 4.0;
  static const double fatKcalPerGram = 9.0;

  // Water tracker
  static const int waterDailyGoal = 8;

  // Recent foods lookup
  static const int recentFoodsDays = 14;
  static const int recentFoodsMaxCount = 5;
}
