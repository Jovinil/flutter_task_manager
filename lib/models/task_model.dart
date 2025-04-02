class Task {
  final int id;
  final String title;
  final String description;
  final int categoryId;
  final DateTime deadline;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.deadline, 
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      categoryId: json['categoryId'],
      deadline: DateTime.parse(json['deadline']), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'deadline': deadline.toIso8601String(), 
    };
  }
}
