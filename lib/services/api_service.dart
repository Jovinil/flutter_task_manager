import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/category_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = "https://jovinil.github.io/task_api/task.json";
  List<Task> _localTasks = [];
  List<Category> _localCategories = [];
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tasks = data['tasks'] as List;
        final categories = data['categories'] as List;
        
        _localTasks = tasks.map((json) => Task.fromJson(json)).toList();
        _localCategories = categories.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }
  Future<List<Task>> getTasks() async {
    if (_localTasks.isEmpty) {
      await fetchData();
    }
    return _localTasks;
  }
  Future<List<Category>> getCategories() async {
    if (_localCategories.isEmpty) {
      await fetchData();
    }
    return _localCategories;
  }

  Future<Task> getTaskById(int id) async {
    if (_localTasks.isEmpty) {
      await fetchData();
    }

    return _localTasks.firstWhere((task) => task.id == id, orElse: () {
      throw Exception("Task with ID $id not found");
    });
  }

  Future<Category> getCategoryById(int id) async {
    if (_localCategories.isEmpty) {
      await fetchData();
    }

    return _localCategories.firstWhere((category) => category.id == id, orElse: () {
      throw Exception("Category with ID $id not found");
    });
  }
  Future<Task> createTask(String title, String description, int categoryId, DateTime deadline) async {
    final newTask = Task(
      id: _localTasks.isEmpty ? 1 : _localTasks.last.id + 1,
      title: title,
      description: description,
      categoryId: categoryId,
      deadline: deadline,
    );

    _localTasks.add(newTask);
    return newTask;
  }
  Future<Task> updateTask(int id, String title, String description, int categoryId, DateTime deadline) async {
    final taskIndex = _localTasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw Exception("Task with ID $id not found");
    }
    final updatedTask = Task(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      deadline: deadline,
    );

    _localTasks[taskIndex] = updatedTask;
    return updatedTask;
  }

  Future<void> deleteTask(int id) async {
    final taskIndex = _localTasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw Exception("Task with ID $id not found");
    }
    _localTasks.removeAt(taskIndex);
  }
}
