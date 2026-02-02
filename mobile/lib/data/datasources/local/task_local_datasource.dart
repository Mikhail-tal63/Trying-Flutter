import 'dart:async';
import 'package:ToDo/data/models/task_model.dart';
import 'package:hive/hive.dart';


class TaskLocalDataSource {
static const String _boxName = 'tasks';  

late Box<TaskModel> _tasBox;
final _taskStreamController = StreamController<List<TaskModel>>.broadcast();

TaskLocalDataSource();

Future<void> init() async {
  if (!Hive.isBoxOpen(_boxName)) {
    _tasBox = await Hive.openBox<TaskModel>(_boxName);  
} else {
  _tasBox = Hive.box<TaskModel>(_boxName);  
}
 //_emitTasksUpdate();
}


}