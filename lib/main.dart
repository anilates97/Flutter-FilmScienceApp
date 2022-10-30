import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/model/movie_app_detail.dart';
import 'package:movie_app/pages/fav_page.dart';
import 'package:movie_app/pages/signup_page.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:movie_app/widget/nav_bar_widget.dart';

import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  FirebaseAuthService _authService = FirebaseAuthService();
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/HomePage':
              return CupertinoPageRoute(builder: (_) => HomePage());
            case '/FavPage':
              return CupertinoPageRoute(builder: (_) => FavPage(MovieDetail()));
          }
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
    // home: _authService.getCurrentUser() == null
    //     ? HomePage()
    //     : NavBarWidget());
  }
}
