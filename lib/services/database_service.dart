import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/services/auth_service.dart';

import '../model/movie_app_detail.dart';

abstract class DatabaseService {
  Future<void> addMovieToDatabase(
      String uID, MovieDetail detail, String backdropUrl, String movieID);
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMovieFromDatabase(
      String movieID);
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchMovieFromFirebase(
      String uID, String movieID);
  Future<void> updateFavInfoFromFirebase(String uID, int movieID);
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMoviesFromFirebase(
      String uID);
  Future<void> deleteMovieFromFirebase(String uID, String movieID);
  Future<void> writeReplyOnMovie(
      String movieName, String reply, String movieID);
  Future<void> writeRepliesOnMovie(
      String movieName, String reply, String movieID);
  Stream<DocumentSnapshot<Map<String, dynamic>>> readReplyOnMovie(
      String movieID);
  Stream<QuerySnapshot<Map<String, dynamic>>> readRepliesOnMovie();
  Future<int> replyCount(String movieID);
}

class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
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
  Future<void> addMovieToDatabase(
      String uID, MovieDetail detail, String backdropUrl, String movieID) {
    return firestore
        .collection("movies")
        .doc(uID)
        .collection("favMovies")
        .doc(movieID)
        .set({
      'id': detail.id,
      'movieName': detail.title,
      'movieSubject': detail.overview,
      'url': backdropUrl,
      'movieCountry': detail.productionCountries == null ||
              detail.productionCountries!.isEmpty
          ? "-"
          : detail.productionCountries![0].name,
      'releaseDate': detail.releaseDate,
      'addedDate': DateTime.now(),
      'fav': true,
    });
  }

  @override
  Future<void> writeReplyOnMovie(
      String movieName, String reply, String movieID) {
    final userId = _authService.getCurrentUser();
    final cleanReply = reply.trim();
    if (userId == null || cleanReply.isEmpty) return Future.value();

    return firestore.collection("replies").doc(movieID).set({
      'id': movieID,
      'movieName': movieName,
      'reply': FieldValue.arrayUnion([
        {'reply': cleanReply, 'userID': userId, 'vote': 0}
      ]),
      'addedDate': DateTime.now(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> writeRepliesOnMovie(
      String movieName, String reply, String movieID) {
    return writeReplyOnMovie(movieName, reply, movieID);
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> readReplyOnMovie(
      String movieID) {
    return firestore.collection("replies").doc(movieID).snapshots();
  }

  @override
  Future<int> replyCount(String movieID) async {
    try {
      final snapshot = await firestore.collection("replies").doc(movieID).get();
      return snapshot.exists ? 1 : 0;
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> readRepliesOnMovie() {
    return firestore.collection("replies").snapshots();
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchMovieFromFirebase(
      String uID, String movieID) {
    return firestore
        .collection("movies")
        .doc(uID)
        .collection("favMovies")
        .doc(movieID)
        .snapshots();
  }

  @override
  Future<void> deleteMovieFromFirebase(String uID, String movieID) {
    try {
      return firestore
          .collection("movies")
          .doc(uID)
          .collection("favMovies")
          .doc(movieID)
          .delete();
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      return Future.value();
    }
  }

  Future<void> likeReply(String movieID, String replyText) async {
    final data = firestore.collection("replies").doc(movieID);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(data);
      final snapshotData = snapshot.data();
      if (!snapshot.exists || snapshotData == null) return;

      final replies = List<Map<String, dynamic>>.from(
        (snapshotData["reply"] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item)),
      );
      final index = replies.indexWhere((item) => item["reply"] == replyText);
      if (index == -1) return;

      replies[index]["vote"] = (replies[index]["vote"] as int? ?? 0) + 1;
      transaction.update(data, {"reply": replies});
    });
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMoviesFromFirebase(
      String uID) {
    return firestore
        .collection("movies")
        .doc(uID)
        .collection("favMovies")
        .orderBy("addedDate", descending: true)
        .snapshots();
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
      debugPrint(e.toString());
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
