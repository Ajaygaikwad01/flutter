import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentuser.dart';

class Oursignupform extends StatefulWidget {
  @override
  _OursignupformState createState() => _OursignupformState();
}

class _OursignupformState extends State<Oursignupform> {
  TextEditingController _uniqueIdController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passswordController = TextEditingController();
  TextEditingController _conformpasswordController = TextEditingController();

  void _signUpUser(String email, String password, String fullName,
      String uniqueId, BuildContext context) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    try {
      String _returnString =
          await _currentuser.signUpUser(email, password, fullName, uniqueId);
      if (_returnString == "Success") {
        Navigator.pop(context);
        await progressdialog.hide();
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

  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true);

    progressdialog.style(
      message: "Loading....",
    );
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Text(
              "Sign Up",
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _uniqueIdController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.label_important),
                hintText: "UniqueId/CollegeId/RollNo"),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_outline), hintText: "Full Name"),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.alternate_email), hintText: "Email"),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _passswordController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline), hintText: "Password"),
            obscureText: true,
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _conformpasswordController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                hintText: "Conform Password"),
            obscureText: true,
          ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () async {
              if (_passswordController.text ==
                  _conformpasswordController.text) {
                await progressdialog.show();
                _signUpUser(
                    _emailController.text,
                    _passswordController.text,
                    _fullNameController.text,
                    _uniqueIdController.text,
                    context);
              } else {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("password doesn't match"),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}
