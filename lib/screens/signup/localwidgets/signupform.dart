import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:worldetor/state/currentuser.dart';

class Oursignupform extends StatefulWidget {
  @override
  _OursignupformState createState() => _OursignupformState();
}

class _OursignupformState extends State<Oursignupform> {
  final formkey = GlobalKey<FormState>();
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
        // await progressdialog.hide();
        setState(() {
          loadingcircle = false;
        });
      } else {
        // await progressdialog.hide();
        setState(() {
          loadingcircle = false;
        });
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(_returnString),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print(e);
      // progressdialog.hide();
      setState(() {
        loadingcircle = false;
      });
    }
  }

  bool loadingcircle = false;
  // ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    // progressdialog = ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: true);

    // progressdialog.style(
    //   message: "Loading....",
    // );
    return ModalProgressHUD(
      inAsyncCall: loadingcircle,
      child: Container(
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
            Form(
              key: formkey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (val) {
                      return val.isEmpty ? "Please provide UniqueId" : null;
                    },
                    controller: _uniqueIdController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.label_important),
                        hintText: "UniqueId/CollegeId/RollNo"),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    validator: (val) {
                      return val.isEmpty
                          ? "Please provide vaild User Name"
                          : null;
                    },
                    controller: _fullNameController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: "Full Name"),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    validator: (val) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val)
                          ? null
                          : "Please provide valid email id";
                    },
                    controller: _emailController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.alternate_email),
                        hintText: "Email"),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    validator: (val) {
                      return val.isEmpty || val.length < 6
                          ? "Minimum 6 character required"
                          : null;
                    },
                    controller: _passswordController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        hintText: "Password"),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    validator: (val) {
                      return val.isEmpty || val.length < 6
                          ? "Minimum 6 character required"
                          : null;
                    },
                    controller: _conformpasswordController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        hintText: "Conform Password"),
                    obscureText: true,
                  ),
                ],
              ),
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
                if (formkey.currentState.validate()) {
                  if (_passswordController.text ==
                      _conformpasswordController.text) {
                    // await progressdialog.show();
                    setState(() {
                      loadingcircle = true;
                    });
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
                }
              },
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
