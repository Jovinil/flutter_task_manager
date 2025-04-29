import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Seed default categories
    await db.insert('categories', {'name': 'work'});
    await db.insert('categories', {'name': 'personal'});
    await db.insert('categories', {'name': 'urgent'});

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        deadline TEXT NOT NULL,
      FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<Category> createCategory(String name) async {
    final db = await database;
    final id = await db.insert('categories', {'name': name});
    return Category(id: id, name: name);
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
      );
    });
  }

  Future<Category> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category(
        id: maps.first['id'] as int,
        name: maps.first['name'] as String,
      );
    }
    throw Exception("Category with ID $id not found");
  }

  Future<Task> createTask(String title, String description, int categoryId, DateTime deadline) async {
    final db = await database;
    final id = await db.insert('tasks', {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'deadline': deadline.toIso8601String(),
    });
    return Task(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      deadline: deadline,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
        categoryId: maps[i]['categoryId'] as int,
        deadline: DateTime.parse(maps[i]['deadline'] as String),
      );
    });
  }

  Future<Task> getTaskById(int id) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task(
        id: maps.first['id'] as int,
        title: maps.first['title'] as String,
        description: maps.first['description'] as String,
        categoryId: maps.first['categoryId'] as int,
        deadline: DateTime.parse(maps.first['deadline'] as String),
      );
    }
    throw Exception("Task with ID $id not found");
  }

  Future<Task> updateTask(int id, String title, String description, int categoryId, DateTime deadline) async {
    final db = await database;
    final updatedCount = await db.update(
      'tasks',
      {
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'deadline': deadline.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updatedCount == 0) {
      throw Exception("Task with ID $id not found");
    }
    return Task(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      deadline: deadline,
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    final deletedCount = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw Exception("Task with ID $id not found");
    }
  }
}
