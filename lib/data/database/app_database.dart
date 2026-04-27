import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/food_item_model.dart';

part 'app_database.g.dart';

class FoodListConverter extends TypeConverter<List<FoodItemModel>, String> {
  const FoodListConverter();

  @override
  List<FoodItemModel> fromSql(String fromDb) {
    final list = jsonDecode(fromDb) as List<dynamic>;
    return list
        .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<FoodItemModel> value) =>
      jsonEncode(value.map((e) => e.toJson()).toList());
}

@DataClassName('UserRow')
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get gender => text()();
  RealColumn get height => real()();
  RealColumn get weight => real()();
  IntColumn get age => integer()();
  TextColumn get goal => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MealLogRow')
class MealLogsTable extends Table {
  @override
  String get tableName => 'meal_logs';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()();
  TextColumn get foodsJson =>
      text().withDefault(const Constant('[]')).map(const FoodListConverter())();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WeightLogRow')
class WeightLogsTable extends Table {
  @override
  String get tableName => 'weight_logs';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [UsersTable, MealLogsTable, WeightLogsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) await migrator.createTable(weightLogsTable);
          if (from < 3) {
            await migrator.addColumn(
                mealLogsTable, mealLogsTable.note);
          }
        },
      );

  Future<UserRow?> getUserByEmail(String email) =>
      (select(usersTable)..where((t) => t.email.equals(email)))
          .getSingleOrNull();

  Future<UserRow?> getUserById(String id) =>
      (select(usersTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertUser(UsersTableCompanion user) =>
      into(usersTable).insert(user);

  Future<void> updateUser(UsersTableCompanion user) =>
      (update(usersTable)..where((t) => t.id.equals(user.id.value)))
          .write(user);

  Future<List<MealLogRow>> getMealLogsByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(mealLogsTable)
          ..where((t) => t.userId.equals(userId) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();
  }

  Future<List<DateTime>> getDatesWithLogs(String userId, int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final rows = await (select(mealLogsTable)
          ..where((t) => t.userId.equals(userId) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
    final dates = rows
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet()
        .toList();
    return dates;
  }

  Future<List<DateTime>> getAllDatesWithLogs(String userId) async {
    final rows = await (select(mealLogsTable)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm(
              expression: t.date, mode: OrderingMode.desc)]))
        .get();
    return rows
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  Future<List<MealLogRow>> getMealLogsByMonth(
      String userId, int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (select(mealLogsTable)
          ..where((t) =>
              t.userId.equals(userId) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();
  }

  Future<void> upsertMealLog(MealLogsTableCompanion log) =>
      into(mealLogsTable).insertOnConflictUpdate(log);

  Future<void> deleteMealLog(String id) =>
      (delete(mealLogsTable)..where((t) => t.id.equals(id))).go();

  Future<List<WeightLogRow>> getWeightLogs(String userId) =>
      (select(weightLogsTable)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm(expression: t.date)]))
          .get();

  Future<void> upsertWeightLog(WeightLogsTableCompanion log) =>
      into(weightLogsTable).insertOnConflictUpdate(log);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'meokrok.db'));
    return NativeDatabase.createInBackground(file);
  });
}
