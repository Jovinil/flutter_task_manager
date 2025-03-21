import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskDetail extends StatefulWidget {
  final int taskId;

  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  late Future<Task> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskFuture = ApiService().getTaskById(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task Details")),
      body: FutureBuilder<Task>(
        future: _taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final task = snapshot.data!;
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
}
