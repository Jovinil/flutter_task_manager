import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class TaskDetail extends StatelessWidget {
  final int taskId;

  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task Details")),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TaskError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is TaskLoaded) {
            final task = state.tasks.firstWhere(
              (task) => task.id == taskId,
              orElse: () => throw Exception("Task with ID $taskId not found"),
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Title:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(task.title, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Text(
                    "Description:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(task.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Text(
                    "Category ID:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(task.categoryId.toString(), style: TextStyle(fontSize: 16)),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      _showEditTaskDialog(context, task);
                    },
                    child: Text("Edit Task"),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("No task found"));
          }
        },
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final TextEditingController titleController = TextEditingController(text: task.title);
    final TextEditingController descriptionController = TextEditingController(text: task.description);
    final TextEditingController categoryIdController =
        TextEditingController(text: task.categoryId.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: categoryIdController,
                decoration: InputDecoration(labelText: "Category ID"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int? categoryId = int.tryParse(categoryIdController.text);
                if (categoryId != null) {
                  context.read<TaskBloc>().add(
                    UpdateTask(
                      task.id,
                      titleController.text,
                      descriptionController.text,
                      categoryId,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid Category ID.")),
                  );
                }
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
