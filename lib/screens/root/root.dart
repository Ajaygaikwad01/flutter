import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:worldetor/screens/login/loginN.dart';
import 'package:worldetor/screens/splashScreen/splashscreen.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/widgets/HomeNavigator.dart';

enum AuthStatus {
  unknown,
  notloggedIn,
  loggedIn,
  notInGroup,
  inGroup,
}

class OurRoot extends StatefulWidget {
  @override
  _OurRootState createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());

      _firebaseMessaging.onIosSettingsRegistered.listen((event) {
        print("ios registerd");
      });
    }
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {
        // print("onResume: $message");
      },
    );
  }

  AuthStatus _authStatus = AuthStatus.unknown;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    String _returnscreen = await _currentUser.onStartUp();

    if (_returnscreen == "Success") {
      setState(() {
        _authStatus = AuthStatus.loggedIn;
      });

      // if (_currentUser.getCurrentUser.groupid != null) {
      //   setState(() {
      //     _authStatus = AuthStatus.inGroup;
      //   });
      // } else {
      //   setState(() {
      //     _authStatus = AuthStatus.notInGroup;
      //   });
      // }
    } else {
      setState(() {
        _authStatus = AuthStatus.notloggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget retval;

    switch (_authStatus) {
      case AuthStatus.unknown:
        retval = OurSplashScreen();
        break;
      case AuthStatus.loggedIn:
        retval = HomeNavigator();
        break;
      case AuthStatus.notloggedIn:
        // retval = Ourlogin();
        retval = OurNewLoginPage();
        break;
      // case AuthStatus.notInGroup:
      //   retval = HomeNavigator();
      //   break;
      // case AuthStatus.inGroup:
      //   // retval = HomeNavigator();
      //   retval = ChangeNotifierProvider(
      //     create: (context) => CurrentGroup(),
      //     child: GroupNavigator(),
      //   );
      //   break;
      default:
    }
    return retval;
  }
}
