import 'package:ToDo/data/models/task_model.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_bloc.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_state.dart';
import 'package:ToDo/presentation/home/Bloc/task_bloc.dart';
import 'package:ToDo/presentation/home/Bloc/task_event.dart';
import 'package:ToDo/presentation/home/Bloc/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

final ScrollController _scrollController = ScrollController();
bool _isFabVisible = true;

void initState{
  super.initState();
  _scrollController.addListener(_scrollController);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<TaskBloc>().add(LoadTasksEvent());
  });
}

@override
void _scrollController(){
  if(_scrollController.position.userScrollDirection == ScrollDirection.reverse)
  {
    if(_isFabVisible){
      setState(() => _isFabVisible = false);
    }
  } else if(_scrollController.position.userScrollDirection == ScrollDirection.forward){
    if(!_isFabVisible){
    setState(() => _isFabVisible = true);
  }
  }
}

@override
void dispose(){
  _scrollController.removeListener(_scrollController);
_scrollController.dispose();
super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(listeners: 
    [BlocListener<AuthBloc,AuthState>(
      listener:(context,state){
        if (state is AuthUnauthenticated){
          Navigator.pushNamedAndRemoveUntil(context, '/login',(route) => false);
        }
      }
       ),
          BlocListener<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
),
            );
          }
        
        if (state is TaskSyncComplete){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content : Text('${state.syncedCount} Tasks synced successfully')
            ,backgroundColor: Colors.green,
            )
          );
        }
        }
       )
      ],
      child: Scaffold(
        appBar: const HomePage(),
        body:BlocBuilder<TaskBloc,TaskState>(
          builder: (context,state){
          if(state is TaskLoading){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(state is TaskError){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(LoadTasksEvent());
                  }, 
                child: const Text("reload"))
              ],
              ),
            );
          }
          if(state is TaskLoaded){
return Column(
  children: [
    const HomeSearhcBar(),
    const FilterChips(),

StatsSummary(stats:state.stats),

Expanded(
  child: RefreshIndicator(
     onRefresh: () async {
      context.read<TaskBloc>().add(LoadTasksEvent(forceRefresh: true));
     },
     child: state.tasks.isEmpty ?
     _buildEmptyState() : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: state.tasks.length,
                              itemBuilder: (context, index) {
                                final task = state.tasks[index];
                                return TaskCard(task: task);
                              },
                            ),
     ) 

)


  ]);



          }
          return const Center(child: CircularProgressIndicator());

          }
          ),
          floatingActionButton: AnimatedOpacity(
          opacity: _isFabVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddTaskBottomSheet(context) ,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
           backgroundColor: Theme.of(context).primaryColor,
           )
          
          ),
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
      );
  }

Widget _buildEmptyState() {
return SingleChildScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
child: Padding(padding: const EdgeInsetsGeometry.all(32.0),
child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const SizedBox(height: 80),
    Icon(Icons.task_outlined
    ,size: 120,
    color: Colors.grey[300],
    ),
    const SizedBox(height: 20),
Text('No tasks found',
      style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
),
const SizedBox(height: 12),
Text('Press to add first task',
  textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
),
         const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddTaskBottomSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
  ],
),
),

);
}

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const AddTaskBottomSheet();
      },
    );
  }



}