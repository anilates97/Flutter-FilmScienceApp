import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:movie_app/services/auth_service.dart';

abstract class Storage {
 uploadImageToFirebase(String movieID,  String userID, File? image);
}

class FirebaseStorageService implements Storage {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  @override
    Future<String>? uploadImageToFirebase(
      String movieName, String userID, File? image) async {
    try {
      Reference ref = _firebaseStorage.ref('/bookApp/$userID/$movieName' ".jpg");
      UploadTask uploadTask = ref.putFile(image!.absolute);
      await Future.value(uploadTask);
      var newUrl = await ref.getDownloadURL();
      print("url:" + newUrl);
      return newUrl;
    } on FirebaseException catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

}