import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends NyController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> loginWithEmail(String email, String password, BuildContext context) async {
    print("[AuthController] Attempting login with email: $email");
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      print("[AuthController] Login success. User: ${response.user?.id}, Session: ${response.session != null}");
      return response.user != null;
    } on AuthException catch (e) {
      print("[AuthController] Login AuthException: ${e.message}");
      showToastDanger(
        title: "Login Failed",
        description: e.message,
      );
      return false;
    } catch (e) {
      print("[AuthController] Login Exception: $e");
      showToastDanger(
        title: "Error",
        description: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, BuildContext context) async {
    print("[AuthController] Attempting signup with email: $email");
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      print("[AuthController] Signup response user: ${response.user?.id}, session: ${response.session != null}");
      if (response.user != null) {
        if (response.session != null) {
          showToastSuccess(
            title: "Success",
            description: "Pendaftaran berhasil!",
          );
          return true;
        } else {
          showToastSuccess(
            title: "Verifikasi Email",
            description: "Pendaftaran berhasil! Silakan periksa email Anda untuk konfirmasi.",
          );
          return false;
        }
      }
      return false;
    } on AuthException catch (e) {
      print("[AuthController] Signup AuthException: ${e.message}");
      showToastDanger(
        title: "Registration Failed",
        description: e.message,
      );
      return false;
    } catch (e) {
      print("[AuthController] Signup Exception: $e");
      showToastDanger(
        title: "Error",
        description: e.toString(),
      );
      return false;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'taskify://login-callback',
      );
    } catch (e) {
      showToastDanger(
        title: "Google Sign-In Failed",
        description: e.toString(),
      );
    }
  }
}
