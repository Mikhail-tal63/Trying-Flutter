import 'dart:async';
import 'package:ToDo/data/models/task_model.dart';
import 'package:ToDo/data/repositories/task_repository.dart';
import 'package:ToDo/presentation/home/Test/task_event.dart';
import 'package:ToDo/presentation/home/Test/task_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  StreamSubscription? _taskSubscription;
  Timer? _syncTimer;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskStatusEvent>(_onToggleTaskStatus);
    on<FilterTasksEvent>(_onFilterTasks);
    on<SyncTasksEvent>(_onSyncTasks);
    on<SearchTasksEvent>(_onSearchTasks);
    on<ClearCompletedEvent>(_onClearCompleted);
    on<SetTaskPriorityEvent>(_onSetTaskPriority);

    _startTaskStream();
    _startAutoSync();
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded || event.forceRefresh) {
      emit(TaskLoading());
    }

    try {
      final tasks = await taskRepository.getTasks();
      final stats = await taskRepository.getTaskStats();
      final filteredTasks = _applyFilters(tasks, null, null);

      emit(TaskLoaded(
        tasks: filteredTasks,
        stats: stats,
      ));
    } catch (e) {
      emit(TaskError(message: 'فشل تحميل المهام: $e'));
    }
  }

  Future<void> _onAddTask(
    AddTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(currentState.copyWith(isSyncing: true));

      try {
        final newTask = await taskRepository.addTask(event.task);
        final updatedTasks = [newTask, ...currentState.tasks];
        final stats = await taskRepository.getTaskStats();

        emit(TaskLoaded(
          tasks: _applyFilters(updatedTasks, currentState.currentFilter, currentState.searchQuery),
          currentFilter: currentState.currentFilter,
          searchQuery: currentState.searchQuery,
          stats: stats,
        ));
      } catch (e) {
        emit(TaskError(message: 'فشل إضافة المهمة: $e'));
      }
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(currentState.copyWith(isSyncing: true));

      try {
        final updatedTask = await taskRepository.updateTask(event.task);
        final updatedTasks = currentState.tasks.map((task) {
          return task.id == updatedTask.id ? updatedTask : task;
        }).toList();

        final stats = await taskRepository.getTaskStats();

        emit(TaskLoaded(
          tasks: _applyFilters(updatedTasks, currentState.currentFilter, currentState.searchQuery),
          currentFilter: currentState.currentFilter,
          searchQuery: currentState.searchQuery,
          stats: stats,
        ));
      } catch (e) {
        emit(TaskError(message: 'فشل تحديث المهمة: $e'));
      }
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(currentState.copyWith(isSyncing: true));

      try {
        await taskRepository.deleteTask(event.taskId, serverId: event.serverId);
        final updatedTasks = currentState.tasks
            .where((task) => task.id != event.taskId)
            .toList();

        final stats = await taskRepository.getTaskStats();

        emit(TaskLoaded(
          tasks: _applyFilters(updatedTasks, currentState.currentFilter, currentState.searchQuery),
          currentFilter: currentState.currentFilter,
          searchQuery: currentState.searchQuery,
          stats: stats,
        ));
      } catch (e) {
        emit(TaskError(message: 'فشل حذف المهمة: $e'));
      }
    }
  }

  Future<void> _onToggleTaskStatus(
    ToggleTaskStatusEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final task = currentState.tasks.firstWhere(
        (t) => t.id == event.taskId,
        orElse: () => throw Exception('المهمة غير موجودة'),
      );

      final updatedTask = task.copyWith(
        status: event.newStatus,
        updatedAt: DateTime.now(),
      );

      add(UpdateTaskEvent(task: updatedTask));
    }
  }

  Future<void> _onFilterTasks(
    FilterTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final filteredTasks = _applyFilters(
        currentState.tasks,
        event.filter,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        tasks: filteredTasks,
        currentFilter: event.filter,
      ));
    }
  }

  Future<void> _onSyncTasks(
    SyncTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskSyncing());

    try {
      await taskRepository.syncTasks();
      final tasks = await taskRepository.getTasks();
      final stats = await taskRepository.getTaskStats();

      emit(TaskSyncComplete(syncedCount: tasks.length));
      
      // إعادة تحميل المهام بعد المزامنة
      add(LoadTasksEvent(forceRefresh: true));
    } catch (e) {
      emit(TaskError(message: 'فشل المزامنة: $e'));
    }
  }

  Future<void> _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final filteredTasks = _applyFilters(
        currentState.tasks,
        currentState.currentFilter,
        event.query.isEmpty ? null : event.query,
      );

      emit(currentState.copyWith(
        tasks: filteredTasks,
        searchQuery: event.query.isEmpty ? null : event.query,
      ));
    }
  }

  Future<void> _onClearCompleted(
    ClearCompletedEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final completedTasks = currentState.tasks
          .where((task) => task.status == TaskStatus.completed)
          .toList();

      for (final task in completedTasks) {
        add(DeleteTaskEvent(taskId: task.id, serverId: task.serverId));
      }
    }
  }

  Future<void> _onSetTaskPriority(
    SetTaskPriorityEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final task = currentState.tasks.firstWhere(
        (t) => t.id == event.taskId,
        orElse: () => throw Exception('المهمة غير موجودة'),
      );

      final updatedTask = task.copyWith(
        priority: event.priority,
        updatedAt: DateTime.now(),
      );

      add(UpdateTaskEvent(task: updatedTask));
    }
  }

  List<TaskModel> _applyFilters(
    List<TaskModel> tasks,
    String? filter,
    String? searchQuery,
  ) {
    List<TaskModel> filteredTasks = tasks;

    // تطبيق فلترة الحالة
    if (filter != null && filter.isNotEmpty) {
      switch (filter) {
        case 'pending':
          filteredTasks = filteredTasks
              .where((task) => task.status == TaskStatus.pending)
              .toList();
          break;
        case 'in_progress':
          filteredTasks = filteredTasks
              .where((task) => task.status == TaskStatus.inProgress)
              .toList();
          break;
        case 'completed':
          filteredTasks = filteredTasks
              .where((task) => task.status == TaskStatus.completed)
              .toList();
          break;
        case 'high_priority':
          filteredTasks = filteredTasks
              .where((task) => task.priority == TaskPriority.high)
              .toList();
          break;
        case 'today':
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          filteredTasks = filteredTasks
              .where((task) =>
                  task.dueDate.isAfter(today) &&
                  task.dueDate.isBefore(today.add(const Duration(days: 1))))
              .toList();
          break;
      }
    }

    // تطبيق البحث
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredTasks = filteredTasks
          .where((task) =>
              task.title.toLowerCase().contains(query) ||
              task.description.toLowerCase().contains(query) ||
              (task.category?.toLowerCase().contains(query) ?? false) ||
              task.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }

    return filteredTasks;
  }

  void _startTaskStream() {
    _taskSubscription = taskRepository.getTasksStream().listen((tasks) {
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final filteredTasks = _applyFilters(
          tasks,
          currentState.currentFilter,
          currentState.searchQuery,
        );

        emit(currentState.copyWith(tasks: filteredTasks));
      }
    });
  }

  void _startAutoSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      add(SyncTasksEvent());
    });
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    _syncTimer?.cancel();
    taskRepository.close();
    return super.close();
  }
}