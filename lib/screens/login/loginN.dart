import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
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
  final formkey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passswordController = TextEditingController();
  void _deletedialog() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Error",
      desc: "Invalid Imformation!",
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        ),
      ],
    ).show();
  }

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
        // await progressdialog.hide();
        setState(() {
          loadingcircle = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeNavigator()),
            (route) => false);
      } else {
        setState(() {
          loadingcircle = false;
        });
        // Scaffold.of(context).showSnackBar(
        //   new SnackBar(
        //     content: Text(_returnString),
        //     duration: Duration(seconds: 1),
        // ),
        // );
        _deletedialog();
      }
    } catch (e) {
      // progressdialog.hide();
      setState(() {
        loadingcircle = false;
      });
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
  bool loadingcircle = false;
  // double _progress;
  // ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    // progressdialog = ProgressDialog(context, isDismissible: false);
    return Scaffold(
      // backgroundColor: Color(0xFF21BFBD),
      backgroundColor: Colors.cyan,
      body: ModalProgressHUD(
        inAsyncCall: loadingcircle,
        child: ListView(
          children: <Widget>[
            SizedBox(height: 25.0),
            Padding(
              padding: EdgeInsets.only(left: 40.0),
              child: Row(
                children: <Widget>[
                  Text("TM'",
                      style: TextStyle(
                          // fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0)),
                  SizedBox(width: 5.0),
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
            SizedBox(height: 20.0),
            Container(
              height: MediaQuery.of(context).size.height - 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  // primary: false,
                  padding: EdgeInsets.only(left: 25.0, right: 20.0, top: 15),
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 4.0),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Form(
                      key: formkey,
                      child: Column(
                        children: [
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
                            height: 10.0,
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
                        ],
                      ),
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
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 80),
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
                          if (formkey.currentState.validate()) {
                            // await progressdialog.show();
                            setState(() {
                              loadingcircle = true;
                            });
                            _loginUser(
                                type: LoginType.email,
                                email: _emailController.text,
                                password: _passswordController.text,
                                context: context);
                          }
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Oursignup()));
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
