import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends NyController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loginWithEmail(String email, String password, BuildContext context) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user != null) {
        routeTo('/home', navigationType: NavigationType.pushAndForgetAll);
      }
    } on AuthException catch (e) {
      showToastDanger(
        title: "Login Failed",
        description: e.message,
      );
    } catch (e) {
      showToastDanger(
        title: "Error",
        description: e.toString(),
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password, BuildContext context) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.user != null) {
        showToastSuccess(
          title: "Success",
          description: "Registration successful! Please check your email for confirmation.",
        );
      }
    } on AuthException catch (e) {
      showToastDanger(
        title: "Registration Failed",
        description: e.message,
      );
    } catch (e) {
      showToastDanger(
        title: "Error",
        description: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'pantrypal://login-callback',
      );
    } catch (e) {
      showToastDanger(
        title: "Google Sign-In Failed",
        description: e.toString(),
      );
    }
  }
}
