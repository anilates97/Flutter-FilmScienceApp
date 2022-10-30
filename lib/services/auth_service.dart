import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Future signUp(String email, String sifre);
  Future signIn(String email, String sifre);
  Future signOut();
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Future signUp(String email, String sifre) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: sifre);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Future signIn(String email, String sifre) async {
    await _auth.signInWithEmailAndPassword(email: email, password: sifre);
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
