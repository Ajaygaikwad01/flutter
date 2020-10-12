import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:worldetor/screens/root/root.dart';

import 'package:worldetor/state/currentuser.dart';

class OurDrawer extends StatefulWidget {
  @override
  _OurDrawerState createState() => _OurDrawerState();
}

class _OurDrawerState extends State<OurDrawer> {
  TextEditingController _uniqueIdController = TextEditingController();
  _dialogbox(BuildContext context, userId) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Unique Id"),
            content: TextFormField(
              controller: _uniqueIdController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.label_important),
                  hintText: "UniqueId/CollegeId/RollNo"),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    await Firestore.instance
                        .collection("users")
                        .document(userId)
                        .updateData({'uniqueId': _uniqueIdController.text});

                    Navigator.of(context).pop();
                    Scaffold.of(context).showSnackBar(
                        new SnackBar(content: new Text("Unique Id Updated")));
                  },
                  child: Text("Sunmit")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Colors.greenAccent[100],
            child: Center(
              child: Consumer<CurrentUser>(
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
                          return Column(
                            children: <Widget>[
                              Container(
                                width: 100,
                                height: 100,
                                margin: EdgeInsets.only(top: 20, bottom: 8),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "lib/assets/google_logo.png"),
                                        fit: BoxFit.fill)),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "   Unique ID :",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    snapshot.data["uniqueId"] ?? "Add UniqueId",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.black),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.edit, color: Colors.red),
                                      onPressed: () {
                                        _dialogbox(
                                            context, value.getCurrentUser.uid);
                                      })
                                ],
                              ),
                              Text(
                                snapshot.data["fullName"],
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                              Text(
                                snapshot.data["email"],
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ],
                          );
                        }
                      });
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("sign Out",
                style: TextStyle(fontSize: 18, color: Colors.black)),
            onTap: () async {
              CurrentUser _currentuser =
                  Provider.of<CurrentUser>(context, listen: false);

              String _returnstring = await _currentuser.signOut();
              if (_returnstring == "Success") {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => OurRoot()),
                    (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
