import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/login/resetpassword.dart';

import 'package:worldetor/screens/signup/signup.dart';
import 'package:worldetor/state/currentuser.dart';

import 'package:worldetor/widgets/HomeNavigator.dart';

enum LoginType { email, google }

class OurNewLoginPage extends StatefulWidget {
  @override
  _OurNewLoginPageState createState() => _OurNewLoginPageState();
}

class _OurNewLoginPageState extends State<OurNewLoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passswordController = TextEditingController();

  void _loginUser({
    @required LoginType type,
    String email,
    String password,
    BuildContext context,
  }) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    try {
      String _returnString;
      switch (type) {
        case LoginType.email:
          _returnString = await _currentuser.logInWithEmail(email, password);
          break;
        case LoginType.google:
          _returnString = await _currentuser.logInWithGoogle();
          break;

        default:
      }

      if (_returnString == "Success") {
        await progressdialog.hide();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeNavigator()),
            (route) => false);
      } else {
        await progressdialog.hide();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(_returnString),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _googleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        width: 100,
        child: OutlineButton(
          splashColor: Colors.grey,
          onPressed: () async {
            //  await progressdialog.show();
            _loginUser(type: LoginType.google, context: context);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
          highlightElevation: 0,
          borderSide: BorderSide(color: Colors.grey),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                    image: AssetImage("lib/assets/google_logo.png"),
                    height: 35.0),
                Padding(
                  padding: const EdgeInsets.only(left: 1),
                  child: Text(
                    ' Google',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool loading = false;

  // double _progress;
  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);
    return Scaffold(
      backgroundColor: Color(0xFF21BFBD),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // IconButton(
                //   icon: Icon(Icons.arrow_back_ios),
                //   color: Colors.white,
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                // ),
                Container(
                    width: 125.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // IconButton(
                        //   icon: Icon(Icons.cached),
                        //   color: Colors.white,
                        //   onPressed: () {
                        //     setState(() {});
                        //   },
                        // ),
                        // IconButton(
                        //   icon: Icon(Icons.menu),
                        //   color: Colors.white,
                        //   onPressed: () {},
                        // )
                      ],
                    ))
              ],
            ),
          ),
          SizedBox(height: 25.0),
          Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: Row(
              children: <Widget>[
                Text("TM",
                    style: TextStyle(
                        // fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
                SizedBox(width: 10.0),
                Expanded(
                  child: Text("meet",
                      style: TextStyle(
                          // fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 24.0)),
                )
              ],
            ),
          ),
          SizedBox(height: 40.0),
          Container(
            height: MediaQuery.of(context).size.height - 185.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
            ),
            child: ListView(
              // primary: false,
              padding: EdgeInsets.only(left: 25.0, right: 20.0, top: 15),
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email),
                      hintText: "Email"),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: _passswordController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: "Password"),
                  obscureText: true,
                ),
                Container(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OurResetpasssword()));
                    },
                    child: Text("Forgot password ?",
                        style: TextStyle(fontStyle: FontStyle.italic)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RaisedButton(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await progressdialog.show();
                      _loginUser(
                          type: LoginType.email,
                          email: _emailController.text,
                          password: _passswordController.text,
                          context: context);
                    },
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Center(child: Text("---or signIn with---")),
                SizedBox(
                  height: 5.0,
                ),
                _googleButton(),
                SizedBox(
                  height: 20.0,
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Oursignup()));
                  },
                  child: Text("Dont have account? Sign Up Here",
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                SizedBox(
                  height: 3.0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
