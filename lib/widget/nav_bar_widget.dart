import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/api/utils.dart';
import 'package:movie_app/model/movie_app_detail.dart';
import 'package:movie_app/pages/fav_page.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/pages/signin_page.dart';
import 'package:movie_app/pages/signup_page.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../pages/home_page.dart';

class NavBarWidget extends ConsumerStatefulWidget {
  String? bookID;
  NavBarWidget({Key? key, this.bookID}) : super(key: key);

  @override
  _NavBarWidgetState createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends ConsumerState<NavBarWidget> {
  FirebaseAuthService _authService = FirebaseAuthService();
  late List<Widget> screensWithLogin = [];

  late HomePage homePage;
  late FavPage favPage;
  late SignInPage signInPage;
  late SignupPage signupPage;

  int currentIndex = 0;

  late PersistentTabController _controllerLogin;

  @override
  void initState() {
    super.initState();
    homePage = HomePage();
    favPage = FavPage(MovieDetail());
    signInPage = SignInPage();
    signupPage = SignupPage();

    _controllerLogin = PersistentTabController(initialIndex: currentIndex);

    screensWithLogin = [homePage, favPage];
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.getCurrentUser() != null) {
      return PersistentTabView(
        context,
        controller: _controllerLogin,

        screens: [homePage],
        items: _navBarsItemsWithLogin(),
        confineInSafeArea: true,
        backgroundColor: MovieUtils.colorDark, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        onItemSelected: (index) => currentIndex = index,
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),

        navBarStyle:
            NavBarStyle.style5, // Choose the nav bar style with this property.
      );
    } else {
      return Container();
    }
  }

  List<PersistentBottomNavBarItem> _navBarsItemsWithLogin() {
    return [
      PersistentBottomNavBarItem(
        title: "Ana sayfa",
        textStyle: TextStyle(color: MovieUtils.colorLight),
        activeColorPrimary: MovieUtils.colorThird,
        inactiveColorPrimary: MovieUtils.colorLight,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/HomePage':
                return CupertinoPageRoute(builder: (_) => HomePage());
              case '/FavPage':
                return CupertinoPageRoute(
                    builder: (_) => FavPage(MovieDetail()));
            }
          },
        ),
        icon: Icon(Icons.home),
      ),
    ];
  }
}
