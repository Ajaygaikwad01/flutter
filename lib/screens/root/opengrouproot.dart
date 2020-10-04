import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/splashScreen/splashscreen.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

import 'package:worldetor/widgets/groupnavigator.dart';

enum AuthStatus {
  unknown,
  notloggedIn,
  loggedIn,
  notInGroup,
  inGroup,
}

class OurGroupRoot extends StatefulWidget {
  @override
  _OurGroupRootState createState() => _OurGroupRootState();
}

class _OurGroupRootState extends State<OurGroupRoot> {
  AuthStatus _authStatus = AuthStatus.unknown;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    CurrentUser _currentUser = Provider.of<CurrentUser>(context, listen: false);
    String _returnscreen = await _currentUser.onStartUp();

    if (_returnscreen == "Success") {
      //   setState(() {
      //     _authStatus = AuthStatus.loggedIn;
      //   });

      //   if (_currentUser.getCurrentUser.groupid != null) {
      setState(() {
        _authStatus = AuthStatus.inGroup;
      });
      //   } else {
      //     setState(() {
      //       _authStatus = AuthStatus.notInGroup;
      //     });
      //   }
      // } else {
      //   setState(() {
      //     _authStatus = AuthStatus.notloggedIn;
      //   });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget retval;

    switch (_authStatus) {
      // retval = HomeNavigator();
      case AuthStatus.unknown:
        retval = OurSplashScreen();
        break;
      case AuthStatus.inGroup:
        retval = ChangeNotifierProvider(
          create: (context) => CurrentGroup(),
          child: GroupNavigator(),
        );
        break;
      default:
    }
    return retval;
  }
}
