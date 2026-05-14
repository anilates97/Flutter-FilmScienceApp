import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthService {
  Future<bool> signUp(String email, String sifre);
  Future<bool> signIn(String email, String sifre);
  Future signOut();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Future<bool> signUp(String email, String sifre) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: sifre);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> signIn(String email, String sifre) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: sifre);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  String? getCurrentUser() {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    } else {
      return null;
    }
  }

  @override
  Future signOut() async {
    await _auth.signOut();
  }
}
