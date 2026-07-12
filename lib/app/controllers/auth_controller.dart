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

      if (response.user == null) {
        // This can happen if the email is already in use (Supabase may return a fake user)
        showToastDanger(
          title: "Pendaftaran Gagal",
          description: "Tidak dapat membuat akun. Email mungkin sudah digunakan.",
        );
        return false;
      }

      // If we already have a session (email confirmation is disabled), we're good
      if (response.session != null) {
        showToastSuccess(
          title: "Berhasil",
          description: "Akun berhasil dibuat! Selamat datang.",
        );
        return true;
      }

      // Email confirmation is enabled — try signing in immediately anyway
      // (works if Supabase is set to not require confirmation, or if user is pre-confirmed)
      try {
        final loginResponse = await _supabase.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (loginResponse.user != null && loginResponse.session != null) {
          showToastSuccess(
            title: "Berhasil",
            description: "Akun berhasil dibuat! Selamat datang.",
          );
          return true;
        }
      } catch (_) {
        // Login after signup failed — email confirmation probably required
      }

      // Fall back: inform user to verify email
      showToastWarning(
        title: "Verifikasi Email",
        description: "Akun dibuat! Silakan cek email Anda untuk konfirmasi, lalu masuk kembali.",
      );
      return false;
    } on AuthException catch (e) {
      print("[AuthController] Signup AuthException: ${e.message}");
      showToastDanger(
        title: "Pendaftaran Gagal",
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
