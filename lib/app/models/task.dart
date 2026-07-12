class Task {
  final String? id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final DateTime? deadline;
  final bool isCompleted;
  final bool isImportant;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category = 'General',
    this.deadline,
    this.isCompleted = false,
    this.isImportant = false,
    this.createdAt,
  });

  // Map JSON responses from Supabase to the Task model
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'General',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      isImportant: json['is_important'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  // Convert the Task instance into JSON maps for insert/update operations
  Map<String, dynamic> toJson({bool includeId = false}) {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'deadline': deadline?.toIso8601String(),
      'is_completed': isCompleted,
      'is_important': isImportant,
    };
    if (includeId && id != null) {
      data['id'] = id;
    }
    return data;
  }
}
