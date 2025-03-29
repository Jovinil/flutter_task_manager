import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../models/category_model.dart'; // Import Category model
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Title", task.title, Icons.title),
                      _buildDetailRow("Description", task.description, Icons.description),
                      _buildDetailRow(
                        "Category",
                        state.categories.firstWhere((category) => category.id == task.categoryId).name,
                        Icons.category,
                      ),
                      _buildDetailRow("Deadline", task.deadline.toLocal().toString().split(' ')[0], Icons.calendar_today),
                      SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showEditTaskDialog(context, task, state.categories);
                          },
                          icon: Icon(Icons.edit),
                          label: Text("Edit Task"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text("No task found"));
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 8.0),
          Text(
            "$label:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, List<Category> categories) {
    final TextEditingController titleController = TextEditingController(text: task.title);
    final TextEditingController descriptionController = TextEditingController(text: task.description);
    DateTime selectedDate = task.deadline;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(task.deadline);
    int selectedCategoryId = task.categoryId;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      if (picked != null && picked != selectedTime) {
        selectedTime = picked;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: SingleChildScrollView(
            child: Column(
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
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(labelText: "Category"),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedCategoryId = value;
                    }
                  },
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text("Select Date"),
                    ),
                    Text("${selectedDate.toLocal()}".split(' ')[0]),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _selectTime(context),
                      child: Text("Select Time"),
                    ),
                    Text("${selectedTime.format(context)}"),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final DateTime finalDeadline = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                context.read<TaskBloc>().add(
                  UpdateTask(
                    task.id,
                    titleController.text,
                    descriptionController.text,
                    selectedCategoryId,
                    finalDeadline,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }
}