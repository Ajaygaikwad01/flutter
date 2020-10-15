import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/screens/login/resetpassword.dart';

import 'package:worldetor/screens/signup/signup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';
import 'package:worldetor/widgets/HomeNavigator.dart';

enum LoginType { email, google }

class OurLoginForm extends StatefulWidget {
  @override
  _OurLoginFormState createState() => _OurLoginFormState();
}

class _OurLoginFormState extends State<OurLoginForm> {
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
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => HomeScreen(),
        //   ),
        // );
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
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        //  await progressdialog.show();
        _loginUser(type: LoginType.google, context: context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("lib/assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
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
    );
  }

  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true);

    progressdialog.style(
      message: "Loading....",
    );
    return Ourcontener(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Text(
              "Sign In",
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.alternate_email), hintText: "Email"),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextFormField(
            controller: _passswordController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline), hintText: "Password"),
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
          RaisedButton(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
              child: Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
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
          SizedBox(
            height: 5.0,
          ),
          Text("---or signIn with---"),
          SizedBox(
            height: 3.0,
          ),
          _googleButton(),
          SizedBox(
            height: 20.0,
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Oursignup()));
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
    );
  }
}
