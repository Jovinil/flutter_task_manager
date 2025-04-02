abstract class TaskEvent {}


class LoadTasks extends TaskEvent {}
class AddTask extends TaskEvent {
  final String title;
  final String description;
  final int categoryId;
  final DateTime deadline; 

  AddTask(this.title, this.description, this.categoryId, this.deadline); 
}

class UpdateTask extends TaskEvent {
  final int id;
  final String title;
  final String description;
  final int categoryId;
  final DateTime deadline;


  UpdateTask(this.id, this.title, this.description, this.categoryId, this.deadline);
}

class DeleteTask extends TaskEvent {
  final int id;


  DeleteTask(this.id);
}
