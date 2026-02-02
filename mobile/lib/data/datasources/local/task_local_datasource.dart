import 'dart:async';
import 'package:ToDo/data/models/task_model.dart';
import 'package:hive/hive.dart';


class TaskLocalDataSource {
  static const String _boxName = 'tasks';
  late Box<TaskModel> _taskBox;
  final _tasksStreamController = StreamController<List<TaskModel>>.broadcast();

  TaskLocalDataSource();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _taskBox = await Hive.openBox<TaskModel>(_boxName);
    } else {
      _taskBox = Hive.box<TaskModel>(_boxName);
    }
    _emitTasksUpdate();
  }

  Future<List<TaskModel>> getTasks() async {
    return _taskBox.values.toList();
  }

  Stream<List<TaskModel>> getTasksStream() {
    return _tasksStreamController.stream;
  }

  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final allTasks = _taskBox.values.toList();
    return allTasks.where((task) => task.status == status).toList();
  }

  Future<List<TaskModel>> getUnsyncedTasks() async {
    final allTasks = _taskBox.values.toList();
    return allTasks.where((task) => !task.isSynced).toList();
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    await _taskBox.clear();
    for (final task in tasks) {
      await _taskBox.put(task.id, task);
    }
    _emitTasksUpdate();
  }

  Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
    _emitTasksUpdate();
  }

  Future<void> updateTask(TaskModel task) async {
    final existingTask = _taskBox.get(task.id);
    if (existingTask != null) {
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now(),
        isSynced: existingTask.serverId == null ? false : task.isSynced,
      );
      await _taskBox.put(task.id, updatedTask);
      _emitTasksUpdate();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
    _emitTasksUpdate();
  }

  Future<void> markTaskAsSynced(String taskId, String serverId) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        isSynced: true,
        serverId: serverId,
        updatedAt: DateTime.now(),
      );
      await _taskBox.put(taskId, updatedTask);
      _emitTasksUpdate();
    }
  }

  Future<void> clearAll() async {
    await _taskBox.clear();
    _emitTasksUpdate();
  }

  void _emitTasksUpdate() {
    final tasks = _taskBox.values.toList();
    _tasksStreamController.add(tasks);
  }

  Future<void> close() async {
    await _tasksStreamController.close();
    await _taskBox.close();
  }
}