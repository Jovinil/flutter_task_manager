import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/services/api_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ApiService apiService;

  TaskBloc(this.apiService) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await apiService.getTasks();
        tasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())); // Correct field
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError("Failed to fetch tasks"));
      }
    });

    on<AddTask>((event, emit) async {
      try {
        final newTask = await apiService.createTask(
          event.title,
          event.description,
          event.categoryId,
          event.deadline, // Include deadline argument
        );
        final updatedTasks = List<Task>.from((state as TaskLoaded).tasks)..add(newTask);
        updatedTasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        emit(TaskLoaded(updatedTasks));
      } catch (e) {
        emit(TaskError("Failed to add task"));
      }
    });

    on<UpdateTask>((event, emit) async {
      try {
        final updatedTask = await apiService.updateTask(
          event.id,
          event.title,
          event.description,
          event.categoryId,
          event.deadline, // Include deadline argument
        );
        final updatedTasks = (state as TaskLoaded).tasks.map((task) {
          return task.id == event.id ? updatedTask : task;
        }).toList();

        updatedTasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())); // Correct field
        emit(TaskLoaded(updatedTasks));
      } catch (e) {
        emit(TaskError("Failed to update task"));
      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await apiService.deleteTask(event.id);
        final updatedTasks = (state as TaskLoaded).tasks
            .where((task) => task.id != event.id)
            .toList();
        emit(TaskLoaded(updatedTasks));
      } catch (e) {
        emit(TaskError("Failed to delete task"));
      }
    });
  }
}
