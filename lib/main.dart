import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/model/movie_app_detail.dart';
import 'package:movie_app/pages/fav_page.dart';
import 'package:movie_app/theme/app_theme.dart';
import 'package:movie_app/widget/cinematic_widgets.dart';

import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AppBootstrap()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
            default:
              return CupertinoPageRoute(builder: (_) => const HomePage());
          }
        },
        debugShowCheckedModeBanner: false,
        title: 'Film Science',
        theme: AppTheme.dark(),
        home: const HomePage());
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({Key? key}) : super(key: key);

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _initializeFuture = Firebase.initializeApp();
  }

  void _retryInitialize() {
    setState(() {
      _initializeFuture = Firebase.initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppSplash(
            errorMessage: "Film Science could not start. Please try again.",
            onRetry: _retryInitialize,
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }

        return const AppSplash();
      },
    );
  }
}
