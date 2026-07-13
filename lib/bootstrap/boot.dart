import 'package:flutter/material.dart';
import '/config/app.dart';
import '/resources/widgets/splash_screen.dart';
import '../resources/widgets/main_widget.dart';
import '/bootstrap/providers.dart';
import 'package:nylo_framework/nylo_framework.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.g.dart';
import '/app/networking/notification_service.dart';

/* Boot
|--------------------------------------------------------------------------
| The boot class is used to initialize your application.
| Providers are booted in the order they are defined.
|-------------------------------------------------------------------------- */

class Boot {
  /// Returns a [BootConfig] containing the setup and boot functions.
  static BootConfig nylo() => BootConfig(
        setup: () async {
          if (AppConfig.showSplashScreen) {
            runApp(SplashScreen.app());
          }

          await _init();
          return await setupApplication(providers);
        },
        boot: (Nylo nylo) async {
          await bootFinished(nylo, providers);

          runApp(Main(nylo));
        },
      );
}

/* Init
|--------------------------------------------------------------------------
| You can use _init to initialize classes, variables, etc.
| It's run before your app providers are booted.
|-------------------------------------------------------------------------- */

Future<void> _init() async {
  // Initialize Supabase Client
  String? url = Env.get('SUPABASE_URL');
  String? anonKey = Env.get('SUPABASE_ANON_KEY');

  // Fallbacks if make:env hasn't been run yet
  url ??= "https://yqwlrgnmgusjdtzaqpqy.supabase.co";
  anonKey ??= "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlxd2xyZ25tZ3VzamR0emFxcHF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNTE1MjcsImV4cCI6MjA5ODgyNzUyN30.fYkLU4T96iz_f5M2oBhHodI9WyTiNLzRSW84UFY63qs";

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
  );

  // Initialize Local Notifications
  await NotificationService().init();
}

