import '/resources/pages/not_found_page.dart';
import '/resources/pages/home_page.dart';
import '/resources/pages/login_page.dart';
import '/resources/pages/add_edit_task_page.dart';
import 'guards/auth_route_guard.dart';
import 'guards/guest_route_guard.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|--------------------------------------------------------------------------
| * [Tip] Create pages faster 🚀
| Terminal: "metro make:page profile_page"

| Learn more https://nylo.dev/docs/7.x/router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      router.add(LoginPage.path, routeGuards: [GuestRouteGuard()]).initialRoute();
      router.add(HomePage.path, routeGuards: [AuthRouteGuard()]);
      router.add(AddEditTaskPage.path, routeGuards: [AuthRouteGuard()]);

      router.add(NotFoundPage.path).unknownRoute();
});
