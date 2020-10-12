import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/screens/root/root.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurCreateGroup extends StatefulWidget {
  @override
  _OurCreateGroupState createState() => _OurCreateGroupState();
}

class _OurCreateGroupState extends State<OurCreateGroup> {
  void _alertdialog() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Failed",
      desc: "Please Add UniqueId in your profile.",
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

  void _createGroup(
      BuildContext context, String groupName, String description) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase().createGroup(
        groupName,
        description,
        _currentuser.getCurrentUser.uid,
        _currentuser.getCurrentUser.fullName,
        _currentuser.getCurrentUser.email,
        _currentuser.getCurrentUser.uniqueId);

    if (_returnString == "Success") {
      progressdialog.hide();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OurRoot(),
          ),
          (route) => false);
    } else {
      progressdialog.hide();
      // showSnackBar(SnackBar(
      //     content: Text("Failed something went wrong"),
      //     duration: Duration(seconds: 1)));
    }
  }

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupdescriptionController = TextEditingController();
  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);
    progressdialog.update(
      message: "Loading....",
    );
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Group"),
        ),
        body: Consumer<CurrentUser>(
            builder: (BuildContext context, value, Widget child) {
          return StreamBuilder(
              stream: Firestore.instance
                  .collection("users")
                  .document(value.getCurrentUser.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.data == null) {
                  return Text("Loading..");
                  // print("null value");
                } else {
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
                                controller: _groupNameController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.group),
                                    hintText: "Group Name"),
                                maxLength: 25,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextFormField(
                                controller: _groupdescriptionController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.description),
                                    hintText: "Group Description"),
                                maxLength: 50,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              RaisedButton(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 80),
                                    child: Text(
                                      "Create",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (snapshot.data["uniqueId"] != null) {
                                      progressdialog.show();
                                      _createGroup(
                                          context,
                                          _groupNameController.text,
                                          _groupdescriptionController.text);
                                    } else {
                                      print("uniqueid not avilable");
                                      _alertdialog();
                                    }
                                  })
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }
              });
        }));
  }
}
