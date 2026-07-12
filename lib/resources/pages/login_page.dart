import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/auth_controller.dart';

class LoginPage extends NyStatefulWidget<AuthController> {
  static RouteView path = ("/login", (_) => LoginPage());

  LoginPage({super.key}) : super(child: () => _LoginPageState());
}

class _LoginPageState extends NyPage<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isRegistering = false;
  bool _isLoading = false;

  @override
  get init => () async {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4), // Warm cream background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Title (Bebas Neue)
                  Text(
                    _isRegistering ? "DAFTAR" : "MASUK",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle (Montserrat)
                  Text(
                    _isRegistering 
                        ? "Buat akun baru untuk mulai mengelola tugas Anda."
                        : "Kembali ke tugas Anda. Selesaikan blok Anda.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Neo-brutalist Container for Form
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF9F2),
                      border: Border.all(color: Colors.black, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(5, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Label
                        Text(
                          "Email",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // Email Text Field (Neo-brutalist style)
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "nama@email.com",
                            hintStyle: GoogleFonts.montserrat(color: Colors.grey[500]),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 1.8),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 2.2),
                              borderRadius: BorderRadius.zero,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red, width: 1.8),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red, width: 2.2),
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          style: GoogleFonts.montserrat(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email tidak boleh kosong";
                            }
                            if (!value.contains("@")) {
                              return "Format email tidak valid";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Kata Sandi",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            if (!_isRegistering)
                              GestureDetector(
                                onTap: () {
                                  showToastWarning(
                                    title: "Lupa Kata Sandi?",
                                    description: "Fitur atur ulang kata sandi sedang dalam pengembangan.",
                                  );
                                },
                                child: Text(
                                  "Lupa?",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: const Color(0xFF9E3A25),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        
                        // Password Text Field (Neo-brutalist style)
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 1.8),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 2.2),
                              borderRadius: BorderRadius.zero,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red, width: 1.8),
                              borderRadius: BorderRadius.zero,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red, width: 2.2),
                              borderRadius: BorderRadius.zero,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: GoogleFonts.montserrat(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kata sandi tidak boleh kosong";
                            }
                            if (value.length < 6) {
                              return "Kata sandi minimal 6 karakter";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button (Neo-brutalist style)
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: CircularProgressIndicator(color: Colors.black),
                                ),
                              )
                            : InkWell(
                                onTap: _handleSubmit,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9E3A25), // Terracotta
                                    border: Border.all(color: Colors.black, width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(3, 3),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isRegistering ? "DAFTAR SEKARANG" : "MASUK",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),

                        // OR divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.black, thickness: 1.2)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                "ATAU",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Colors.black, thickness: 1.2)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Google Sign-In Button
                        InkWell(
                          onTap: _handleGoogleSignIn,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  "https://developers.google.com/identity/images/g-logo.png",
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24);
                                  },
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Masuk dengan Google",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bottom Mode Toggle Text
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                        _formKey.currentState?.reset();
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: _isRegistering 
                                ? "Sudah punya akun? " 
                                : "Belum punya akun? ",
                          ),
                          TextSpan(
                            text: _isRegistering ? "MASUK" : "DAFTAR SEKARANG",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF9E3A25),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    print("[Login] Submitting form. Form valid: ${_formKey.currentState!.validate()}");
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    bool success = false;

    print("[Login] Calling auth method. Registering: $_isRegistering, Email: $email");
    if (_isRegistering) {
      success = await widget.controller.signUpWithEmail(email, password, context);
    } else {
      success = await widget.controller.loginWithEmail(email, password, context);
    }

    print("[Login] Auth completed. Success: $success, Mounted: $mounted");
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        print("[Login] Redirecting to /home...");
        routeTo('/home', navigationType: NavigationType.pushAndForgetAll);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await widget.controller.signInWithGoogle(context);
  }
}
