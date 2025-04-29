
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'task_detail.dart';

import '../db/database_helper.dart';

// Helper function to choose an icon based on category id.
IconData getCategoryIcon(int categoryId) {
  switch (categoryId) {
    case 1:
      return Icons.work;
    case 2:
      return Icons.home;
    case 3:
      return Icons.school;
    default:
      return Icons.category;
  }
}

class TaskList extends StatelessWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        centerTitle: true,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskError) {
            return Center(child: Text(state.message));
          }
          if (state is TaskLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return _buildTaskItem(context, task, state.categories);
              },
            );
          }
          return const Center(child: Text("No tasks available."));
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              _showAddTaskDialog(context);
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

Widget _buildTaskItem(BuildContext context, Task task, List<Category> categories) {
  final category = categories.firstWhere(
    (category) => category.id == task.categoryId,
    orElse: () => Category(id: 0, name: "Unknown"),
  );
  final categoryIcon = getCategoryIcon(task.categoryId);
  return Card(
    elevation: 2.0,
    margin: const EdgeInsets.symmetric(horizontal: 16.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      title: Text(
        task.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          Text(task.description),
          const SizedBox(height: 8.0),
          Text("Category: ${category.name}"),
          const SizedBox(height: 4.0),
          Text(
            "Deadline: ${task.deadline.toLocal().toString().substring(0,16)}",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
      trailing: Icon(categoryIcon, color: Colors.blueAccent),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetail(taskId: task.id)),
        );
      },
    ),
  );
}

void _showAddTaskDialog(BuildContext context) {
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
            child: _AddTaskForm(scrollController: scrollController),
          );
        },
      );
    },
  );
}


class _AddTaskForm extends StatefulWidget {
  final ScrollController scrollController;
  
  const _AddTaskForm({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int? selectedCategoryId;

  List<Category> categories = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await apiService.getCategories();
    setState(() {
      categories = loadedCategories;
      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first.id;
      }
    });
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
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
              validator: (value) => value == null ? "Please select a category" : null,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectDate,
                    child: Text("Select Date: ${selectedDate.toLocal().toString().substring(0,10)}"),
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
                  child: const Text("Add"),
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
                        AddTask(
                          titleController.text,
                          descriptionController.text,
                          selectedCategoryId!,
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
