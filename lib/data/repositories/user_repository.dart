import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/user_model.dart';

class UserRepository {
  const UserRepository(this._db);

  final AppDatabase _db;

  static String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<UserModel?> login(String email, String password) async {
    final row = await _db.getUserByEmail(email);
    if (row == null) return null;
    if (row.passwordHash != _hash(password)) return null;
    return _toModel(row);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _db.insertUser(UsersTableCompanion.insert(
      id: id,
      name: name,
      email: email,
      passwordHash: _hash(password),
      gender: 'male',
      height: 170.0,
      weight: 65.0,
      age: 25,
      goal: 'maintain',
      createdAt: now,
    ));
    final row = await _db.getUserById(id);
    return _toModel(row!);
  }

  Future<UserModel?> getUserById(String id) async {
    final row = await _db.getUserById(id);
    return row != null ? _toModel(row) : null;
  }

  Future<void> updateProfile(UserModel user) async {
    await _db.updateUser(UsersTableCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email),
      passwordHash: Value(user.passwordHash),
      gender: Value(user.gender.name),
      height: Value(user.height),
      weight: Value(user.weight),
      age: Value(user.age),
      goal: Value(user.goal.name),
      createdAt: Value(user.createdAt),
    ));
  }

  Future<bool> emailExists(String email) async {
    final row = await _db.getUserByEmail(email);
    return row != null;
  }

  UserModel _toModel(UserRow row) => UserModel(
        id: row.id,
        name: row.name,
        email: row.email,
        passwordHash: row.passwordHash,
        gender: Gender.values.firstWhere((g) => g.name == row.gender),
        height: row.height,
        weight: row.weight,
        age: row.age,
        goal: Goal.values.firstWhere((g) => g.name == row.goal),
        createdAt: row.createdAt,
      );
}
