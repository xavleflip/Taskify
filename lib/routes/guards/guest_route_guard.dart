import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GuestRouteGuard extends NyRouteGuard {
  GuestRouteGuard();

  @override
  Future<bool> canOpen(BuildContext? context, NyArgument? data) async {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null;
  }

  @override
  redirectTo(BuildContext? context, NyArgument? data) async {
    await routeTo('/home', navigationType: NavigationType.pushAndForgetAll);
  }
}
