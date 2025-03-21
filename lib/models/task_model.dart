class Task {
  final int id;
  final String title;
  final String description;
  final int categoryId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
    };
  }
}
