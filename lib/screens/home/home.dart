// ignore: avoid_web_libraries_in_flutter
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'package:worldetor/screens/root/opengrouproot.dart';

import 'package:worldetor/screens/home/Constants.dart';
import 'package:worldetor/screens/home/creategroup.dart';
import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/screens/home/joingroup.dart';

import 'package:worldetor/services/database.dart';

import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openGroup(BuildContext context, String groupId) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase().openGroup(
      groupId,
      _currentuser.getCurrentUser.uid,
    );

    if (_returnString == "Success") {
      progressdialog.hide();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OurGroupRoot(),
        ),
      );
      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => OurRoot(),
      //     ),
      //     (route) => false);
    }
  }

  Future<void> _removegroup(context, userId, groupId) async {
    await Firestore.instance.collection("users").document(userId).updateData({
      "listgroup": FieldValue.arrayRemove([groupId]),
    });
    await Firestore.instance.collection("groups").document(groupId).updateData({
      "members": FieldValue.arrayRemove([userId]),
    });
    Scaffold.of(context)
        .showSnackBar(new SnackBar(content: new Text("Group deleted")));
  }

  bool loading = false;
  ProgressDialog progressdialog;
  @override
  Widget build(BuildContext context) {
    progressdialog = ProgressDialog(context, isDismissible: false);
    progressdialog.update(
      message: "Opening...",
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[100],
        title: Text("home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () async {
              setState(() {});
              print("Refreshing");
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.add),
            onSelected: (String choice) {
              if (choice == Constant.CreateGroup) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OurCreateGroup(),
                  ),
                );
              } else if (choice == Constant.JoinGroup) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OurJoinGroup(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return Constant.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      drawer: OurDrawer(),
      body: Consumer<CurrentUser>(
          builder: (BuildContext context, value, Widget child) {
        if (value.getCurrentUser.listGroup == null) {
          return Center(child: Text("Create OR join Group"));
        } else {
          return StreamBuilder(
              stream: Firestore.instance
                  .collection("users")
                  .document(value.getCurrentUser.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.data == null) {
                  return Container(
                    child: Center(
                      child: Text("Loading...."),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data["listgroup"].length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.30,
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.redAccent,
                              icon: Icons.delete,
                              onTap: () {
                                setState(() {
                                  loading = !loading;
                                });
                                _removegroup(context, value.getCurrentUser.uid,
                                    snapshot.data["listgroup"][index]);
                              },
                            )
                          ],
                          child: Ourcontener(
                            child: ListTile(
                                title: StreamBuilder(
                                  stream: Firestore.instance
                                      .collection("groups")
                                      .document(
                                          snapshot.data["listgroup"][index])
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.data == null) {
                                      return Text("Loading....");
                                    } else {
                                      return Column(
                                        children: [
                                          Text(snapshot.data["name"]),
                                          Text(snapshot.data["Description"] ??
                                              "Description"),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                // subtitle:
                                //     Text(snapshot.data["Description"] ?? "Description"),
                                onTap: () {
                                  progressdialog.show();
                                  _openGroup(context,
                                      snapshot.data["listgroup"][index]);
                                }),
                          ),
                        ),
                      );
                    },
                  );
                }
              });
        }
      }),
    );
  }
}
