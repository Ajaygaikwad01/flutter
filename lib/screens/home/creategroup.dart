import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
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

  void _createGroup(BuildContext context, String groupName, String description,
      String uniqueId, String notificationTocken) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase().createGroup(
      groupName,
      description,
      _currentuser.getCurrentUser.uid,
      _currentuser.getCurrentUser.fullName,
      _currentuser.getCurrentUser.email,
      uniqueId,
      notificationTocken,
    );

    if (_returnString == "Success") {
      setState(() {
        loadingcircle = false;
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OurRoot(),
          ),
          (route) => false);
    } else {
      setState(() {
        loadingcircle = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Failed something went wrong"),
          duration: Duration(seconds: 1)));
    }
  }

  final formkey = GlobalKey<FormState>();
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupdescriptionController = TextEditingController();
  bool loadingcircle = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loadingcircle,
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              "Create Group",
              style: TextStyle(color: Colors.white),
            ),
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
                    return CircularProgressIndicator();
                  } else {
                    return ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Ourcontener(
                            child: Column(
                              children: <Widget>[
                                Form(
                                  key: formkey,
                                  child: TextFormField(
                                    validator: (val) {
                                      return val.isEmpty
                                          ? "Please provide vaild Group Name"
                                          : null;
                                    },
                                    controller: _groupNameController,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.group),
                                        hintText: "Group Name"),
                                    minLines: 1,
                                    maxLength: 25,
                                  ),
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
                                      if (formkey.currentState.validate()) {
                                        if (snapshot.data["uniqueId"] != null) {
                                          // progressdialog.show();
                                          setState(() {
                                            loadingcircle = true;
                                          });
                                          _createGroup(
                                              context,
                                              _groupNameController.text,
                                              _groupdescriptionController.text,
                                              snapshot.data["uniqueId"],
                                              snapshot
                                                  .data["notificationTocken"]);
                                        } else {
                                          print("uniqueid not avilable");
                                          _alertdialog();
                                        }
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
          })),
    );
  }
}
