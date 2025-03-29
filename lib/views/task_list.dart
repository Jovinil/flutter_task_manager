import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../models/category_model.dart'; // Import Category model
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'task_detail.dart';

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tasks")),
      body: BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) return Center(child: CircularProgressIndicator());
        if (state is TaskError) return Center(child: Text(state.message));
        if (state is TaskLoaded) {
          return ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return _buildTaskItem(context, task, state.categories);
            },
          );
        }
        return Center(child: Text("No tasks available."));
      },
    ),
      floatingActionButton: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoaded) {
            return FloatingActionButton(
              onPressed: () {
                _showAddTaskDialog(context, state.categories);
              },
              child: Icon(Icons.add),
            );
          }
          return Container();
        },
      ),
    );
  }
}

Widget _buildTaskItem(BuildContext context, Task task, List<Category> categories) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.description),
          SizedBox(height: 4.0),
          Text("Category: ${categories.firstWhere((category) => category.id == task.categoryId).name}"),
          Text("Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetail(taskId: task.id),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(task.id));
            },
          ),
        ],
      ),
    ),
  );
}

void _showAddTaskDialog(BuildContext context, List<Category> categories) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int? selectedCategoryId;

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

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
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
              decoration: InputDecoration(labelText: "Category"),
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                selectedCategoryId = value;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategoryId != null) {
                      final DateTime finalDeadline = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      context.read<TaskBloc>().add(
                        AddTask(
                          titleController.text,
                          descriptionController.text,
                          selectedCategoryId!,
                          finalDeadline,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select a category.")),
                      );
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}