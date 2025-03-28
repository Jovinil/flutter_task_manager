abstract class TaskEvent {}


class LoadTasks extends TaskEvent {}
class AddTask extends TaskEvent {
  final String title;
  final String description;
  final int categoryId;
  final DateTime deadline; // Added deadline property

  AddTask(this.title, this.description, this.categoryId, this.deadline); // Include deadline in constructor
}

class UpdateTask extends TaskEvent {
  final int id;
  final String title;
  final String description;
  final int categoryId;
  final DateTime deadline; // Added deadline property



  UpdateTask(this.id, this.title, this.description, this.categoryId, this.deadline); // Include deadline in constructor
}

class DeleteTask extends TaskEvent {
  final int id;


  DeleteTask(this.id);
}
