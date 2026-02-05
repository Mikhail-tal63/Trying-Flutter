



import 'package:ToDo/data/models/task_model.dart';
import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final bool forceRefresh;

const LoadTasksEvent({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];

}

class AddTaskEvent extends TaskEvent {

final TaskModel task;

const AddTaskEvent({required this.task});

@override
  List<Object> get props => [task];

}

class UpdateTaskEvent extends TaskEvent {
final TaskModel task;

const UpdateTaskEvent({required this.task});

@override
  List<Object> get props => [task];

}

class DeleteTaskEvent extends TaskEvent {
final String taskId;
final String? serverId;

const DeleteTaskEvent({required this.taskId,required this.serverId});

@override
  List<Object> get props => [taskId, serverId ?? ''];


}

class ToggleTaskStatusEvent extends TaskEvent {
  final String taskId;
  final String? serverId;
  final TaskStatus newStatus;

  const ToggleTaskStatusEvent({
    required this.taskId,
    this.serverId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [taskId, serverId ?? '', newStatus];
}

class FilterTasksEvent extends TaskEvent {
  final String filter;

  const FilterTasksEvent({required this.filter});

  @override
  List<Object> get props => [filter];
}

class SyncTasksEvent extends TaskEvent {}

class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class ClearCompletedEvent extends TaskEvent {}

class SetTaskPriorityEvent extends TaskEvent {
  final String taskId;
  final String? serverId;
  final TaskPriority priority;

  const SetTaskPriorityEvent({
    required this.taskId,
    this.serverId,
    required this.priority,
  });

  @override
  List<Object> get props => [taskId, serverId ?? '', priority];
}

class TasksUpdated extends TaskEvent {
  final List<TaskModel> tasks;

  const TasksUpdated(this.tasks);

  @override
  List<Object> get props => [tasks];
}
