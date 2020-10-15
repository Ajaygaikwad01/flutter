import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurResetpasssword extends StatefulWidget {
  @override
  _OurResetpassswordState createState() => _OurResetpassswordState();
}

class _OurResetpassswordState extends State<OurResetpasssword> {
  void _alertdialog() {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Send",
      desc: "Check your email.",
      buttons: [
        // DialogButton(
        //   child: Text(
        //     "FLAT",
        //     style: TextStyle(color: Colors.white, fontSize: 20),
        //   ),
        //   onPressed: () => Navigator.pop(context),
        //   color: Color.fromRGBO(0, 179, 134, 1.0),
        // ),
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
        )
      ],
    ).show();
  }

  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
      ),
      body: Consumer<CurrentUser>(
        builder: (BuildContext context, value, Widget child) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                    // children: [BackButton()],
                    ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Ourcontener(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.alternate_email),
                            hintText: "Email"),
                        maxLength: 25,
                      ),
                      RaisedButton(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 50),
                            child: Text(
                              "Send Email",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          onPressed: () {
                            value.onresetPassowrd(_emailController.text);
                            _alertdialog();
                          })
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
