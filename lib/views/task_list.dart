
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'task_detail.dart';

class TaskList extends StatelessWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure Material 3 is enabled in the app theme (to be set in main.dart or theme configuration)
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
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

Widget _buildTaskItem(BuildContext context, Task task, List<Category> categories) {
  // Use Card with subtle elevation and modern rounded corners.
  final categoryName = categories.firstWhere((category) => category.id == task.categoryId,
      orElse: () => Category(id: 0, name: "Unknown")).name;
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
          Text("Category: $categoryName"),
          const SizedBox(height: 4.0),
          Text(
            "Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
      trailing: Wrap(
        spacing: 4.0,
        children: [
          IconButton(
            tooltip: "View Details",
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetail(taskId: task.id)),
              );
            },
          ),
          IconButton(
            tooltip: "Delete Task",
            icon: const Icon(Icons.delete, color: Colors.red),
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // allows the sheet to expand with keyboard
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
            child: _AddTaskForm(categories: categories, scrollController: scrollController),
          );
        },
      );
    },
  );
}

class _AddTaskForm extends StatefulWidget {
  final List<Category> categories;
  final ScrollController scrollController;
  
  const _AddTaskForm({Key? key, required this.categories, required this.scrollController}) : super(key: key);

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
              decoration: const InputDecoration(labelText: "Category"),
              items: widget.categories.map((category) {
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
                    child: Text("Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
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
