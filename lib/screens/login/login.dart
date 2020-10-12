import 'package:flutter/material.dart';
import 'package:worldetor/screens/login/localwidgets/loginform.dart';

class Ourlogin extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Image.asset("lib/assets/logo.PNG"),
                ),
                // SizedBox(
                //   height: 5.0,
                // ),
                OurLoginForm()
              ],
            ),
          )
        ],
      ),
    );
  }
}
