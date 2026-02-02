import 'dart:async';
import 'package:ToDo/data/datasources/local/task_local_datasource.dart';
import 'package:ToDo/data/datasources/remote/task_api.dart';
import 'package:ToDo/data/models/task_model.dart';

class TaskRepository {
  final TaskApi taskApi;
  final TaskLocalDataSource localDataSource;
  bool _isOnline = true;

  TaskRepository({
    required this.taskApi,
    required this.localDataSource,
  });

  Future<void> init() async {
    await localDataSource.init();
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      if (_isOnline) {
        final tasks = await taskApi.getTasks();
        await localDataSource.saveTasks(tasks);
        return tasks;
      } else {
        return await localDataSource.getTasks();
      }
    } catch (e) {
      return await localDataSource.getTasks();
    }
  }

  Stream<List<TaskModel>> getTasksStream() {
    return localDataSource.getTasksStream();
  }

  Future<TaskModel> addTask(TaskModel task) async {
    try {
      if (_isOnline) {
        final serverTask = await taskApi.createTask(task);
        final finalTask = serverTask.copyWith(
          isSynced: true,
          serverId: serverTask.id,
        );
        await localDataSource.addTask(finalTask);
        return finalTask;
      } else {
        final localTask = task.copyWith(isSynced: false);
        await localDataSource.addTask(localTask);
        return localTask;
      }
    } catch (e) {
      final localTask = task.copyWith(isSynced: false);
      await localDataSource.addTask(localTask);
      return localTask;
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      if (_isOnline && task.serverId != null) {
        final serverTask = await taskApi.updateTask(task.serverId!, task);
        final updatedTask = serverTask.copyWith(isSynced: true);
        await localDataSource.updateTask(updatedTask);
        return updatedTask;
      } else {
        final localTask = task.copyWith(isSynced: false);
        await localDataSource.updateTask(localTask);
        return localTask;
      }
    } catch (e) {
      final localTask = task.copyWith(isSynced: false);
      await localDataSource.updateTask(localTask);
      return localTask;
    }
  }

  Future<void> deleteTask(String taskId, {String? serverId}) async {
    try {
      if (_isOnline && serverId != null) {
        await taskApi.deleteTask(serverId);
      }
    } catch (e) {
      print('Deleting from server failed Task will be deleted locally $e');
    } finally {
      await localDataSource.deleteTask(taskId);
    }
  }

  Future<void> syncTasks() async {
    try {
      final unsyncedTasks = await localDataSource.getUnsyncedTasks();

      for (final task in unsyncedTasks) {
        if (task.serverId == null) {
          final serverTask = await taskApi.createTask(task);
          await localDataSource.markTaskAsSynced(task.id, serverTask.id);
        } else {
          await taskApi.updateTask(task.serverId!, task);
          await localDataSource.markTaskAsSynced(task.id, task.serverId!);
        }
      }
    } catch (e) {
      print('Sync failed$e');
      rethrow;
    }
  }
/******************************************************** */
  Future<Map<String, int>> getTaskStats() async {
    final tasks = await localDataSource.getTasks();

    final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
    final inProgress =
        tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final completed =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final highPriority =
        tasks.where((t) => t.priority == TaskPriority.high).length;

    return {
      'total': tasks.length,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
      'highPriority': highPriority,
    };
  }

  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
  }

  Future<void> close() async {
    await localDataSource.close();
  }
}
