import 'package:flutter/material.dart';
import 'package:movie_app/pages/home_page.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
        title: const Text("Create account"),
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
                  const Icon(Icons.movie_filter_rounded,
                      color: AppColors.gold, size: 44),
                  const SizedBox(height: 18),
                  Text("Start your watchlist", style: AppText.hero),
                  const SizedBox(height: 8),
                  Text(
                    "Create an account to keep favorites and collect quotes.",
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
                      onPressed: _isLoading ? null : _signUp,
                      icon: Icon(_isLoading
                          ? Icons.hourglass_top_rounded
                          : Icons.person_add_alt_1),
                      label: Text(_isLoading
                          ? "Creating account..."
                          : "Create account"),
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

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    final success = await _firebaseAuthService.signUp(
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
        const SnackBar(content: Text("Signup failed. Check your details.")),
      );
    }
  }
}
