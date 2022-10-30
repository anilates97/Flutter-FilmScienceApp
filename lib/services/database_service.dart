import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/model/reply.dart';
import 'package:movie_app/services/auth_service.dart';

import '../model/movie_app_detail.dart';

abstract class DatabaseService {
  void addMovieToDatabase(
      MovieDetail detail, String backdropUrl, String movieID);
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMovieFromDatabase(
      String movieID);
  Stream<DocumentSnapshot<Map<String, dynamic>>>? fetchMovieFromFirebase(
      String uID, String movieID);
  Future<void> updateFavInfoFromFirebase(String uID, int movieID);
  Stream<QuerySnapshot<Map<String, dynamic>>>? fetchMoviesFromFirebase(
      String uID);
  void deleteMovieFromFirebase(String uID, String movieID);
  Future<void> writeReplyOnMovie(
      String movieName, String reply, String movieID);
  Future<void> writeRepliesOnMovie(String reply, String movieID);
  Stream<DocumentSnapshot<Map<String, dynamic>>> readReplyOnMovie(
      String movieID);
  Stream<QuerySnapshot<Map<String, dynamic>>> readRepliesOnMovie();
  Future<int> replyCount(String movieID);
}

class FirebaseDatabaseService implements DatabaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuthService _authService = FirebaseAuthService();
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMovieFromDatabase(
      String movieID) {
    return firestore
        .collection("movies")
        .doc(_authService.getCurrentUser())
        .collection("favMovies")
        .snapshots();
  }

  @override
  void addMovieToDatabase(
      MovieDetail detail, String backdropUrl, String movieID) {
    firestore
        .collection("movies")
        .doc(_authService.getCurrentUser())
        .collection("favMovies")
        .doc(movieID)
        .set({
      'id': detail.id,
      'movieName': detail.title,
      'movieSubject': detail.overview,
      'url': backdropUrl,
      'movieCountry': detail.productionCountries == null
          ? "-"
          : detail.productionCountries![0].name,
      'releaseDate': detail.releaseDate,
      'addedDate': DateTime.now(),
      'fav': false,
    });
  }

  @override
  Future<void> writeReplyOnMovie(
      String movieName, String reply, String movieID) {
    return firestore.collection("replies").doc(movieID).set({
      'id': movieID,
      'movieName': movieName,
      'reply': FieldValue.arrayUnion([
        {'reply': reply, 'userID': _authService.getCurrentUser(), 'vote': 0}
      ]),
      'addedDate': DateTime.now(),
    });
  }

  @override
  Future<void> writeRepliesOnMovie(String reply, String movieID) {
    return firestore.collection("replies").doc(movieID).update({
      'reply': FieldValue.arrayUnion([
        {'reply': reply, 'userID': _authService.getCurrentUser(), 'vote': 0}
      ]),
    });
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> readReplyOnMovie(
      String movieID) {
    return firestore.collection("replies").doc(movieID).snapshots();
  }

  @override
  Future<int> replyCount(String movieID) {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection("reply");
      DocumentReference documentReference = collectionReference.doc(movieID);

      var snapshot = documentReference.snapshots();
      if (snapshot.length == null) {
        return Future.value(0);
      } else {
        return Future.value(1);
      }
    } on FirebaseException catch (e) {
      return Future.value(0);
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> readRepliesOnMovie() {
    return firestore.collection("replies").snapshots();
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>>? fetchMovieFromFirebase(
      String uID, String movieID) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Stream<DocumentSnapshot<Map<String, dynamic>>> querySnapshot = firestore
          .collection("movies")
          .doc(uID)
          .collection("favMovies")
          .doc(movieID)
          .snapshots();

      return querySnapshot;
    } on FirebaseException catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  void deleteMovieFromFirebase(String uID, String movieID) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      firestore
          .collection("movies")
          .doc(uID)
          .collection("favMovies")
          .doc(movieID)
          .delete();
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }

  Future<void> likeReply(String movieID) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    print("MOVIE ID SERVICE: $movieID");
    final data = firebaseFirestore.collection("replies").doc(movieID);

    var snap = data.get();

    snap.then((value) {
      print("value::: ${value.data()!['reply'][1]}");
    });
    //final data = firebaseFirestore.collection("replies").doc(movieID);

    firebaseFirestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(data);
      // Note: this could be done without a transaction
      //       by updating the population using FieldValue.increment()
      final newVotes = snapshot.get("vote") + 1;
      transaction.update(data, {"vote": newVotes});
    }).then(
      (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updating document $e"),
    );
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>>? fetchMoviesFromFirebase(
      String uID) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = firestore
          .collection("movies")
          .doc(uID)
          .collection("favMovies")
          .snapshots();

      return querySnapshot;
    } on FirebaseException catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> isDuplicateUniqueName(int uniqueName, String? userID) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('movies')
        .doc(userID)
        .collection("favMovies")
        .where('id', isEqualTo: uniqueName)
        .get();
    return query.docs.isNotEmpty;
  }

  @override
  Future<void> updateFavInfoFromFirebase(String uID, int movieID) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      return firestore
          .collection("movies")
          .doc(uID)
          .collection("favMovies")
          .doc("$movieID")
          .update({'fav': true});
    } on FirebaseException catch (e) {
      print(e.toString());
      throw Exception('HATA Update FAV');
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }
}
