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
      
      // Update local storage cache on success
      await cacheTasksLocally([...activeTasks, ...completedTasks]);
    } catch (e) {
      print("Database error: $e. Falling back to local cache.");
      // Fallback to cache
      final cachedTasks = await loadCachedTasks();
      activeTasks = cachedTasks.where((t) => !t.isCompleted).toList();
      completedTasks = cachedTasks.where((t) => t.isCompleted).toList();
    } finally {
      isLoading = false;
      updateState('dashboard'); // Turn off loader, render items
    }
  }

  // Save list to local storage
  Future<void> cacheTasksLocally(List<Task> tasks) async {
    try {
      final List<Map<String, dynamic>> taskJsonList = tasks.map((t) => t.toJson(includeId: true)).toList();
      await NyStorage.save('cached_tasks', taskJsonList);
    } catch (e) {
      print("Failed to cache tasks: $e");
    }
  }

  // Load from local storage if network request fails
  Future<List<Task>> loadCachedTasks() async {
    try {
      final cachedData = await NyStorage.read<List<dynamic>>('cached_tasks');
      if (cachedData != null) {
        return cachedData.map((json) => Task.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    } catch (e) {
      print("Failed to load cached tasks: $e");
    }
    return [];
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
        isImportant: task.isImportant,
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
        isImportant: task.isImportant,
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

  Future<void> deleteTask(Task task) async {
    // Optimistic removal
    if (task.isCompleted) {
      completedTasks.remove(task);
    } else {
      activeTasks.remove(task);
    }
    updateState('dashboard');

    try {
      await _db.deleteTask(task.id!);
      // Refresh cache after deletion
      await cacheTasksLocally([...activeTasks, ...completedTasks]);
    } catch (e) {
      // Revert if deletion fails
      await loadTasks();
    }
  }
}
