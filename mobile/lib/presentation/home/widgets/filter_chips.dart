
import 'package:ToDo/presentation/home/Bloc/task_bloc.dart';
import 'package:ToDo/presentation/home/Bloc/task_event.dart';
import 'package:ToDo/presentation/home/Bloc/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        String currentFilter = 'all';
        if (state is TaskLoaded) {
          currentFilter = state.currentFilter ?? 'all';
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip(context, 'All', 'all', currentFilter),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Pending', 'pending', currentFilter),
              const SizedBox(width: 8),
              _buildFilterChip(context, 'Completed', 'completed', currentFilter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value, String currentFilter) {
    final isSelected = currentFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          context.read<TaskBloc>().add(FilterTasksEvent(filter: value));
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}
