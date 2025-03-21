abstract class TaskEvent {}


class LoadTasks extends TaskEvent {}
class AddTask extends TaskEvent {
  final String title;
  final String description;
  final int categoryId;

  AddTask(this.title, this.description, this.categoryId);
}
class UpdateTask extends TaskEvent {
  final int id;
  final String title;
  final String description;
  final int categoryId;


  UpdateTask(this.id, this.title, this.description, this.categoryId);
}
class DeleteTask extends TaskEvent {
  final int id;


  DeleteTask(this.id);
}
