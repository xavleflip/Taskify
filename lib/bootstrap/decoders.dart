import '/app/controllers/auth_controller.dart';
import '/app/controllers/task_controller.dart';
import '/app/models/task.dart';
/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/7.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  Task: (data) => Task.fromJson(data),
  List<Task>: (data) =>
      List.from(data).map((json) => Task.fromJson(json)).toList(),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/7.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  // ...
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/7.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  AuthController: () => AuthController(),
  TaskController: () => TaskController(),

  // ...
};
