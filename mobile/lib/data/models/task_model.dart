import 'package:flutter/material.dart';
import 'package:hive/hive.dart';



@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low('low', 'Low', Color(0xFF4CAF50)),
  
  @HiveField(1)
  medium('medium', 'Medium', Color(0xFFFF9800)),
  
  @HiveField(2)
  high('high', 'High', Color(0xFFF44336));

  final String value;
  final String label;
  final Color color;
  
  const TaskPriority(this.value, this.label, this.color);
  
  factory TaskPriority.fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

@HiveType(typeId: 2)
enum TaskStatus {
  @HiveField(0)
  pending('pending', 'Pending', Icons.access_time, Colors.orange),
  
  @HiveField(1)
  inProgress('inProgress', 'In Progress', Icons.autorenew, Colors.blue),
  
  @HiveField(2)
  completed('completed', 'Completed', Icons.check_circle, Colors.green);

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  
  const TaskStatus(this.value, this.label, this.icon, this.color);
  
  factory TaskStatus.fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  DateTime dueDate;
  
  @HiveField(4)
  TaskPriority priority;
  
  @HiveField(5)
  TaskStatus status;
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  DateTime? updatedAt;
  
  @HiveField(8)
  String? category;
  
  @HiveField(9)
  List<String> tags;
  
  @HiveField(10)
  bool isSynced;
  
  @HiveField(11)
  String? serverId;
  
  @HiveField(12)
  String? userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.tags = const [],
    this.isSynced = true,
    this.serverId,
    this.userId,
  });

  factory TaskModel.createNew({
    required String title,
    required String description,
    required DateTime dueDate,
    TaskPriority priority = TaskPriority.medium,
    TaskStatus status = TaskStatus.pending,
    String? category,
    List<String> tags = const [],
    String? userId,
  }) {
    final now = DateTime.now();
    return TaskModel(
      id: 'local_${now.millisecondsSinceEpoch}',
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      status: status,
      createdAt: now,
      tags: tags,
      category: category,
      isSynced: false,
      userId: userId,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      priority: TaskPriority.fromString(json['priority'] ?? 'medium'),
      status: TaskStatus.fromString(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isSynced: true,
      serverId: json['_id'] ?? json['id'],
      userId: json['userId'] ?? json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (serverId != null) '_id': serverId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.value,
      'status': status.value,
      'category': category,
      'tags': tags,
      if (userId != null) 'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toSyncJson() {
    return {
      'id': id,
      'serverId': serverId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.value,
      'status': status.value,
      'category': category,
      'tags': tags,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    List<String>? tags,
    bool? isSynced,
    String? serverId,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, status: ${status.label}, priority: ${priority.label})';
  }
}