import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:movie_app/pages/home_page.dart';
import 'package:movie_app/services/auth_service.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                hintText: "E-mail giriniz"
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _sifreController,
                decoration: const InputDecoration(
                hintText: "Şifre giriniz"
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: () {
                 _firebaseAuthService.signUp(_emailController.text, _sifreController.text);
                Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
              }, child: const Text("Kayıt Ol")),
            )
          ],
        ),
      ),
    );
  }
}