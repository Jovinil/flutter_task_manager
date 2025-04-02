import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../models/category_model.dart'; 
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class TaskDetail extends StatelessWidget {
  final int taskId;

  const TaskDetail({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: "Delete Task",
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  final state = context.read<TaskBloc>().state;
                  if (state is TaskLoaded) {
                    try {
                      final task = state.tasks.firstWhere((task) => task.id == taskId);
                      context.read<TaskBloc>().add(DeleteTask(task.id));
                      Navigator.pop(context);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task not found")),
                      );
                    }
                  }
                },
              );
            },
          )
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
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
                      _buildDetailRow("Deadline", task.deadline.toLocal().toString().substring(0, 16), Icons.calendar_today),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showEditTaskDialog(context, task, state.categories);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Task"),
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
            return const Center(child: Text("No task found"));
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
          const SizedBox(width: 8.0),
          Text(
            "$label:",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: _EditTaskForm(
                task: task,
                categories: categories,
                scrollController: scrollController,
              ),
            );
          },
        );
      },
    );
  }
}

class _EditTaskForm extends StatefulWidget {
  final Task task;
  final List<Category> categories;
  final ScrollController scrollController;

  const _EditTaskForm({
    Key? key,
    required this.task,
    required this.categories,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<_EditTaskForm> createState() => _EditTaskFormState();
}

class _EditTaskFormState extends State<_EditTaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late int selectedCategoryId;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    selectedDate = widget.task.deadline;
    selectedTime = TimeOfDay.fromDateTime(widget.task.deadline);
    selectedCategoryId = widget.task.categoryId;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
              validator: (value) => value == null || value.isEmpty ? "Please enter a title" : null,
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              validator: (value) => value == null || value.isEmpty ? "Please enter a description" : null,
            ),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              decoration: const InputDecoration(labelText: "Category"),
              items: widget.categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                }
              },
              validator: (value) => value == null ? "Please select a category" : null,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectDate,
                    child: Text("Select Date: ${selectedDate.toLocal().toString().substring(0, 10)}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectTime,
                    child: Text("Select Time: ${selectedTime.format(context)}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton(
                  child: const Text("Update"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final DateTime finalDeadline = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      context.read<TaskBloc>().add(
                        UpdateTask(
                          widget.task.id,
                          titleController.text,
                          descriptionController.text,
                          selectedCategoryId,
                          finalDeadline,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
