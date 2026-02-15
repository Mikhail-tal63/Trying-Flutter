import 'package:ToDo/presentation/auth/bloc/auth/auth_bloc.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_event.dart';
import 'package:ToDo/presentation/auth/bloc/auth/auth_state.dart';
import 'package:ToDo/presentation/home/Bloc/task_bloc.dart';
import 'package:ToDo/presentation/home/Bloc/task_event.dart';
import 'package:ToDo/presentation/home/Bloc/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${state.user.name}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your daily tasks',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            );
          }
          return const Text('Tasks');
        },
      ),
      actions: [
        // زر المزامنة
        BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.sync),
                  if (state is TaskLoaded && state.isSyncing)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: const SizedBox(
                          width: 8,
                          height: 8,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                context.read<TaskBloc>().add( SyncTasksEvent());
              },
              tooltip: 'Sync Tasks',
            );
          },
        ),
        
        // زر الإعدادات
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add( LogoutEvent());
            } else if (value == 'clear_completed') {
              context.read<TaskBloc>().add( ClearCompletedEvent());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'clear_completed',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 20),
                  SizedBox(width: 8),
                  Text('Clear Completed'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),//nigga
      ],
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
    );
  }
}