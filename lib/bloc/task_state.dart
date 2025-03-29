import 'package:equatable/equatable.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Category> categories; // Add categories

  TaskLoaded(this.tasks, this.categories); // Update constructor

  @override
  List<Object> get props => [tasks, categories]; // Include categories in props
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);

  @override
  List<Object> get props => [message];
}