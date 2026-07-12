import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/supabase_service.dart';
import '/app/models/task.dart';

class TaskController extends NyController {
  final SupabaseService _db = SupabaseService();
  
  List<Task> activeTasks = [];
  List<Task> completedTasks = [];
  bool isLoading = false;

  Future<void> loadTasks() async {
    isLoading = true;
    updateState('dashboard'); // Trigger loading spinner on Dashboard screen
    
    try {
      activeTasks = await _db.fetchActiveTasks();
      completedTasks = await _db.fetchHistoryTasks();
    } catch (e) {
      print("Database error: $e");
    } finally {
      isLoading = false;
      updateState('dashboard'); // Turn off loader, render items
    }
  }

  Future<void> toggleStatus(Task task) async {
    final nextStatus = !task.isCompleted;
    
    // Optimistic UI updates
    if (task.isCompleted) {
      completedTasks.remove(task);
      activeTasks.add(Task(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        category: task.category,
        deadline: task.deadline,
        isCompleted: false,
        createdAt: task.createdAt
      ));
    } else {
      activeTasks.remove(task);
      completedTasks.add(Task(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        category: task.category,
        deadline: task.deadline,
        isCompleted: true,
        createdAt: task.createdAt
      ));
    }
    updateState('dashboard');

    try {
      await _db.updateTaskStatus(task.id!, nextStatus);
    } catch (e) {
      // Revert if API call fails
      await loadTasks();
    }
  }
}
