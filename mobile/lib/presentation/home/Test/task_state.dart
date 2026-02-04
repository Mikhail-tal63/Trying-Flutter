import 'package:ToDo/data/models/task_model.dart';
import 'package:equatable/equatable.dart';



abstract class TaskState extends Equatable {
const TaskState();

@override
List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {

final List<TaskModel> tasks;
final String? currentFilter;
final String? searchQuery;
final Map<String,int> stats;
final bool isSyncing;

const TaskLoaded({
  required this.tasks,
  this.currentFilter,
  this.searchQuery,
  required this.stats,
  required this.isSyncing,
});

@override
  List<Object> get props => [tasks, currentFilter ?? '', searchQuery ?? '', stats, isSyncing];


}

class TaskSyncing extends TaskState {}

class TaskSyncComplete extends TaskState {
  final int syncedCount;

  const TaskSyncComplete({required this.syncedCount});


  @override
  List<Object> get props => [syncedCount];

}

class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object> get props => [message];
}


