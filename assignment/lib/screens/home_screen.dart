import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/task_card.dart';
import '../widgets/quote_widget.dart';

/// Home screen displaying motivational quote, filter chips,
/// and the real-time task list with CRUD actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  int _selectedFilter = 0; // 0 = All, 1 = Pending, 2 = Completed

  /// Returns the current user's UID.
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  /// Returns a greeting based on time of day.
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Returns the user's display name or email.
  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'User';
  }

  /// Handles user logout with confirmation.
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authService.signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: $e'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  /// Shows a confirmation dialog before deleting a task.
  Future<void> _confirmDelete(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteTask(_userId, task.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task deleted successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  /// Toggles the completion status of a task.
  Future<void> _toggleComplete(TaskModel task) async {
    try {
      await _firestoreService.toggleComplete(
        _userId,
        task.id,
        task.isCompleted,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  /// Filters the task list based on the selected filter chip.
  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    switch (_selectedFilter) {
      case 1: // Pending
        return tasks.where((t) => !t.isCompleted).toList();
      case 2: // Completed
        return tasks.where((t) => t.isCompleted).toList();
      default: // All
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _userName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          // Logout button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _handleLogout,
              icon: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 22,
              ),
              tooltip: 'Sign Out',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Motivational Quote Card
            const QuoteWidget(),

            // Filter chips
            _buildFilterChips(theme),
            const SizedBox(height: 16),

            // Task list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getTasks(_userId),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error state
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 56,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Something went wrong',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please try again later',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Parse tasks from Firestore snapshots
                  final allTasks = snapshot.data?.docs
                          .map((doc) => TaskModel.fromFirestore(doc))
                          .toList() ??
                      [];

                  final filteredTasks = _filterTasks(allTasks);

                  // Empty state
                  if (filteredTasks.isEmpty) {
                    return _buildEmptyState(theme, allTasks.isEmpty);
                  }

                  // Task list
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onToggleComplete: () => _toggleComplete(task),
                        onEdit: () {
                          Navigator.pushNamed(
                            context,
                            '/add-edit-task',
                            arguments: task,
                          );
                        },
                        onDelete: () => _confirmDelete(task),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // FAB to add new task
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-edit-task'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Builds the filter chips row (All / Pending / Completed).
  Widget _buildFilterChips(ThemeData theme) {
    final filters = ['All', 'Pending', 'Completed'];
    final icons = [
      Icons.list_rounded,
      Icons.pending_actions_rounded,
      Icons.check_circle_outline_rounded,
    ];

    return Row(
      children: List.generate(filters.length, (index) {
        final isSelected = _selectedFilter == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedFilter = index),
            label: Text(
              filters[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            avatar: Icon(
              icons[index],
              size: 16,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
            selectedColor: theme.colorScheme.primary,
            checkmarkColor: Colors.white,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          ),
        );
      }),
    );
  }

  /// Builds the empty state widget when no tasks exist.
  Widget _buildEmptyState(ThemeData theme, bool noTasksAtAll) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              noTasksAtAll
                  ? Icons.add_task_rounded
                  : Icons.filter_list_off_rounded,
              size: 56,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            noTasksAtAll ? 'No tasks yet' : 'No matching tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            noTasksAtAll
                ? 'Tap the + button to create your first task'
                : 'Try changing the filter to see your tasks',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
