import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class ApiService {
  final String baseUrl = "https://jovinil.github.io/task_api/task.json";
  List<Task> _localTasks = []; 

  // Fetch all tasks from GitHub Pages and store them locally
  Future<List<Task>> getTasks() async {
    if (_localTasks.isEmpty) {
      try {
        final response = await http.get(Uri.parse(baseUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body); 
          final tasks = data['tasks'] as List; 
          _localTasks = tasks.map((json) => Task.fromJson(json)).toList(); 
          throw Exception("Failed to load tasks: ${response.statusCode}");
        }
      } catch (e) {
        print('Error fetching tasks: $e');
        rethrow;
      }
    }
    return _localTasks; // Return local tasks
  }

  // Create a new task locally
  Future<Task> createTask(String title, String description, int categoryId) async {
    final newTask = Task(
      id: _localTasks.isEmpty ? 1 : _localTasks.last.id + 1, 
      title: title,
      description: description,
      categoryId: categoryId,
    );
    _localTasks.add(newTask);
    return newTask;
  }

  // Update an existing task locally
  Future<Task> updateTask(int id, String title, String description, int categoryId) async {
    final taskIndex = _localTasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw Exception("Task with ID $id not found");
    }
    final updatedTask = Task(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
    );
    _localTasks[taskIndex] = updatedTask;
    return updatedTask;
  }

  // Delete a task locally
  Future<void> deleteTask(int id) async {
    final taskIndex = _localTasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw Exception("Task with ID $id not found");
    }
    _localTasks.removeAt(taskIndex);
  }
}
