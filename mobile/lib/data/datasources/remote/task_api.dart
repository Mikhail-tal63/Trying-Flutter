import 'dart:convert';
import 'package:ToDo/core/constants/api_endpoints.dart';
import 'package:ToDo/core/utils/storage_helper.dart';
import 'package:ToDo/data/models/task_model.dart';
import 'package:http/http.dart' as http;

class TaskApi {
  final http.Client client;

  TaskApi({required this.client});

  Future<Map<String, String>> _getHeaders() async {
    final token = StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiEndpoints.baseUrl}/tasks'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List tasks = data['data'] ?? [];
          return tasks.map((task) => TaskModel.fromJson(task)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load tasks');
        }
      } else {
        throw Exception('Server error : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error $e');
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiEndpoints.baseUrl}/tasks'),
        headers: await _getHeaders(),
        body: jsonEncode(task.toSyncJson()),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return TaskModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to add task');
        }
      } else {
        throw Exception('Server error : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error $e');
    }
  }
  Future<TaskModel> updateTask(String taskId, TaskModel task) async {
    try {
      final response = await client.put(
        Uri.parse('${ApiEndpoints.baseUrl}/tasks')
        ,headers: await _getHeaders(),
        body: jsonEncode(task.toJson()),
      
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return TaskModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Updating failed');
        }
      } else{
        throw Exception('Server error : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final response = await client.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/tasks/$taskId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Deleting task failed ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(' Deleting task failed $e');
    }
  }

  Future<void> syncTasks(List<TaskModel> tasks) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiEndpoints.baseUrl}/tasks/sync'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'tasks': tasks.map((task) => task.toSyncJson()).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(' Sync failed ${response.statusCode}');
    
      }
    } catch (e) {
      throw Exception('Sync failed $e');
    }
  }

}
