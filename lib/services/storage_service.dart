import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

abstract class Storage {
  Future<String?> uploadImageToFirebase(
      String movieID, String userID, File? image);
}

class FirebaseStorageService implements Storage {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  @override
  Future<String?> uploadImageToFirebase(
      String movieName, String userID, File? image) async {
    if (image == null) return null;
    try {
      Reference ref = _firebaseStorage.ref('/bookApp/$userID/$movieName' ".jpg");
      UploadTask uploadTask = ref.putFile(image.absolute);
      await Future.value(uploadTask);
      var newUrl = await ref.getDownloadURL();
      return newUrl;
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}
