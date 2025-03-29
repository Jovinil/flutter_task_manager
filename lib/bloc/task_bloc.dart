import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/models/category_model.dart'; // Import Category model
import 'package:task_manager/services/api_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ApiService apiService;

  TaskBloc(this.apiService) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
        print("Loading tasks..."); // Add logging for loading tasks

      emit(TaskLoading());
      try {
        final tasks = await apiService.getTasks();
        final categories = await apiService.getCategories(); // Fetch categories
        tasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        emit(TaskLoaded(tasks, categories)); // Include categories in state
        print("Tasks loaded: ${tasks.length} tasks"); // Log the number of tasks loaded

      } catch (e) {
        emit(TaskError("Failed to fetch tasks and categories"));
        print("Error fetching tasks: $e"); // Log the error

      }
    });

    on<AddTask>((event, emit) async {
      try {
        final newTask = await apiService.createTask(
          event.title,
          event.description,
          event.categoryId,
          event.deadline,
        );
        final updatedTasks = List<Task>.from((state as TaskLoaded).tasks)..add(newTask);
        updatedTasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        emit(TaskLoaded(updatedTasks, (state as TaskLoaded).categories)); // Pass categories
      } catch (e) {
        emit(TaskError("Failed to add task"));
        print("Error adding task: $e"); // Log the error

      }
    });

    on<UpdateTask>((event, emit) async {
      try {
        final updatedTask = await apiService.updateTask(
          event.id,
          event.title,
          event.description,
          event.categoryId,
          event.deadline,
        );
        final updatedTasks = (state as TaskLoaded).tasks.map((task) {
          return task.id == event.id ? updatedTask : task;
        }).toList();

        updatedTasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        emit(TaskLoaded(updatedTasks, (state as TaskLoaded).categories)); // Pass categories
      } catch (e) {
        emit(TaskError("Failed to update task"));
        print("Error updating task: $e"); // Log the error

      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await apiService.deleteTask(event.id);
        final updatedTasks = (state as TaskLoaded).tasks
            .where((task) => task.id != event.id)
            .toList();
        emit(TaskLoaded(updatedTasks, (state as TaskLoaded).categories)); // Pass categories
        print("Task deleted with ID: ${event.id}"); // Log the deleted task ID

      } catch (e) {
        emit(TaskError("Failed to delete task"));
        print("Error deleting task: $e"); // Log the error

      }
    });
  }
}
