import 'package:ToDo/presentation/home/Bloc/task_bloc.dart';
import 'package:ToDo/presentation/home/Bloc/task_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _filters = [
    {'value': 'all', 'label': 'All', 'icon': Icons.list, 'color': Colors.blue},
    {'value': 'pending', 'label': 'Pending ', 'icon': Icons.access_time, 'color': Colors.orange},
    {'value': 'in_progress', 'label': 'On Progress', 'icon': Icons.autorenew, 'color': Colors.blue},
    {'value': 'completed', 'label': 'Complated', 'icon': Icons.check_circle, 'color': Colors.green},
    {'value': 'high_priority', 'label': 'High piority', 'icon': Icons.flag, 'color': Colors.red},
    {'value': 'today', 'label': 'For today ', 'icon': Icons.today, 'color': Colors.purple},
  ];

  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);
    context.read<TaskBloc>().add(FilterTasksEvent(filter: filter));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => _onFilterSelected(filter['value']),
              label: Text(
                filter['label'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              avatar: Icon(
                filter['icon'],
                size: 18,
                color: isSelected ? Colors.white : filter['color'],
              ),
              backgroundColor: Colors.grey[100],
              selectedColor: filter['color'],
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? filter['color'] : Colors.grey[300]!,
                  width: isSelected ? 0 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}