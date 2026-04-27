enum Gender { male, female }

enum Goal { lose, maintain, bulk }

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.goal,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final Gender gender;
  final double height;
  final double weight;
  final int age;
  final Goal goal;
  final DateTime createdAt;

  double get dailyCalorieGoal {
    final bmr = gender == Gender.male
        ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);

    const activityFactor = 1.55;
    final tdee = bmr * activityFactor;

    return switch (goal) {
      Goal.lose => tdee * 0.8,
      Goal.maintain => tdee,
      Goal.bulk => tdee * 1.15,
    };
  }

  double get bmi => weight / ((height / 100) * (height / 100));
  String get bmiLabel {
    if (bmi < 18.5) return '저체중';
    if (bmi < 23.0) return '정상';
    if (bmi < 25.0) return '과체중';
    return '비만';
  }

  double get dailyProteinGoal => weight * 1.6;
  double get dailyCarbGoal => dailyCalorieGoal * 0.40 / 4;
  double get dailyFatGoal => dailyCalorieGoal * 0.30 / 9;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    Gender? gender,
    double? height,
    double? weight,
    int? age,
    Goal? goal,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
