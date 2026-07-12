import 'package:supabase_flutter/supabase_flutter.dart';
import '/app/models/task.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch active tasks for current authenticated user
  Future<List<Task>> fetchActiveTasks() async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('is_completed', false)
        .order('created_at', ascending: false);

    return (response as List).map((taskJson) => Task.fromJson(taskJson)).toList();
  }

  // Fetch completed (history) tasks for current authenticated user
  Future<List<Task>> fetchHistoryTasks() async {
    final response = await _client
        .from('tasks')
        .select()
        .eq('is_completed', true)
        .order('deadline', ascending: false);

    return (response as List).map((taskJson) => Task.fromJson(taskJson)).toList();
  }

  // Create a new task in Supabase
  Future<Task> createTask(Task task) async {
    final response = await _client
        .from('tasks')
        .insert(task.toJson())
        .select()
        .single();
    
    return Task.fromJson(response);
  }

  // Update complete properties of a task
  Future<Task> updateTask(Task task) async {
    if (task.id == null) throw Exception("Task ID cannot be null during updates.");
    
    final response = await _client
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id!)
        .select()
        .single();

    return Task.fromJson(response);
  }

  // Toggle tasks completion status (Active <-> History transition)
  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    await _client
        .from('tasks')
        .update({'is_completed': isCompleted})
        .eq('id', taskId);
  }

  // Permanently delete a task
  Future<void> deleteTask(String taskId) async {
    await _client
        .from('tasks')
        .delete()
        .eq('id', taskId);
  }
}
