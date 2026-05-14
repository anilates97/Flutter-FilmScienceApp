import 'package:flutter/material.dart';
import 'package:movie_app/pages/home_page.dart';
import 'package:movie_app/pages/signup_page.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CinematicScaffold(
      appBar: AppBar(
        title: const Text("Login"),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_movies_rounded,
                      color: AppColors.gold, size: 44),
                  const SizedBox(height: 18),
                  Text("Welcome back", style: AppText.hero),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to save favorites and write memorable quotes.",
                    style: AppText.muted,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.email_outlined, color: AppColors.muted),
                      hintText: "E-mail",
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _sifreController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.lock_outline, color: AppColors.muted),
                      hintText: "Password",
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _signIn,
                      icon: Icon(_isLoading
                          ? Icons.hourglass_top_rounded
                          : Icons.login),
                      label: Text(_isLoading ? "Signing in..." : "Login"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text("Create a new account"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    final success = await _firebaseAuthService.signIn(
      _emailController.text.trim(),
      _sifreController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Check your account.")),
      );
    }
  }
}
