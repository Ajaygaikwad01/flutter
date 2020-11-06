import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/screens/root/opengrouproot.dart';
import 'package:worldetor/screens/home/Constants.dart';
import 'package:worldetor/screens/home/creategroup.dart';
import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourNewContainer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

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

  void _requestSenddialog() {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Request Sent",
      desc: "Contact to Group Admin.",
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

  void _sendJoinRequest(BuildContext context, String groupId, String uniqueId,
      String notificationTocken) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    DocumentSnapshot _docref =
        await Firestore.instance.collection("groups").document(groupId).get();
    if (_docref.exists) {
      String _returnString = await OurDatabase().joinGroupRequest(
          groupId,
          _currentuser.getCurrentUser.uid,
          _currentuser.getCurrentUser.fullName,
          _currentuser.getCurrentUser.email,
          uniqueId,
          notificationTocken);

      if (_returnString == "Success") {
        setState(() {
          loadingcircle = false;
        });
        _requestSenddialog();
      } else {
        setState(() {
          loadingcircle = false;
        });
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Failed something went wrong"),
            duration: Duration(seconds: 1)));
      }
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
  TextEditingController _joinIdController = TextEditingController();
  _joinGroupdialogbox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Consumer<CurrentUser>(
            builder: (BuildContext context, value, Widget child) {
              return StreamBuilder(
                  stream: Firestore.instance
                      .collection("users")
                      .document(value.getCurrentUser.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    return AlertDialog(
                      title: Text("Send Join Request"),
                      content: Form(
                        key: formkey,
                        child: TextFormField(
                          validator: (val) {
                            return val.isEmpty
                                ? "Please provide vaild GroupId"
                                : null;
                          },
                          controller: _joinIdController,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.group),
                              hintText: "GroupId"),
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel")),
                        FlatButton(
                            onPressed: () {
                              if (formkey.currentState.validate()) {
                                if (snapshot.data["uniqueId"] != null) {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    loadingcircle = true;
                                  });

                                  _sendJoinRequest(
                                      context,
                                      _joinIdController.text,
                                      snapshot.data["uniqueId"],
                                      snapshot.data["notificationTocken"]);

                                  _joinIdController.clear();
                                } else {
                                  _alertdialog();
                                }
                              }
                            },
                            child: Text("Send")),
                      ],
                    );
                  });
            },
          );
        });
  }

  void _deletedialog(userId, groupId) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Leave Group",
      desc: "Are you Sure?",
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "Leave",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _removegroup(userId, groupId);
            Navigator.pop(context);
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void _openGroup(BuildContext context, String groupId) async {
    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    String _returnString = await OurDatabase().openGroup(
      groupId,
      _currentuser.getCurrentUser.uid,
    );
    if (_returnString == "Success") {
      setState(() {
        loadingcircle = false;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OurGroupRoot(),
        ),
      );
    } else {
      setState(() {
        loadingcircle = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Failed something went wrong"),
          duration: Duration(seconds: 1)));
    }
  }

  void _removegroup(userId, groupId) async {
    await Firestore.instance.collection("users").document(userId).updateData({
      "listgroup": FieldValue.arrayRemove([groupId]),
    });
    await Firestore.instance.collection("groups").document(groupId).updateData({
      "members": FieldValue.arrayRemove([userId]),
    });
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Group Deleted"), duration: Duration(seconds: 1)));
  }

  bool loading = false;
  bool loadingcircle = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            tooltip: "Refresh",
            icon: Icon(
              Icons.cached_outlined,
            ),
            onPressed: () async {
              setState(() {});
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      Text("Refreshed"),
                    ],
                  ),
                  duration: Duration(seconds: 1)));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.add,
            ),
            onSelected: (String choice) {
              if (choice == Constant.CreateGroup) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OurCreateGroup(),
                  ),
                );
              } else if (choice == Constant.JoinGroup) {
                _joinGroupdialogbox(context);
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
      body: ModalProgressHUD(
        inAsyncCall: loadingcircle,
        child: Consumer<CurrentUser>(
            builder: (BuildContext context, value, Widget child) {
          if (value.getCurrentUser.listGroup == null) {
            return Center(child: Text("Create OR Join Group"));
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
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data["listgroup"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return StreamBuilder(
                            stream: Firestore.instance
                                .collection("groups")
                                .document(snapshot.data["listgroup"][index])
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot2) {
                              if (snapshot2.data == null) {
                                return Container(
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.30,
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                        caption: 'Leave',
                                        color: Colors.redAccent,
                                        icon: Icons.highlight_remove_rounded,
                                        onTap: () {
                                          setState(() {
                                            loading = !loading;
                                          });

                                          _deletedialog(
                                              value.getCurrentUser.uid,
                                              snapshot2.data.documentID);
                                        },
                                      )
                                    ],
                                    child: Bounce(
                                      duration: Duration(milliseconds: 110),
                                      onPressed: () async {
                                        setState(() {
                                          loadingcircle = true;
                                        });
                                        _openGroup(
                                            context, snapshot2.data.documentID);
                                      },
                                      child: OurNewcontener(
                                        child: Material(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      snapshot2.data["name"] ??
                                                          "Loading..",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16)),
                                                  Text(
                                                      snapshot2.data[
                                                              "Description"] ??
                                                          "Description",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.black45)),
                                                  SizedBox(
                                                    height: 25,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text("Created By: ",
                                                          style: TextStyle(
                                                              fontSize: 15)),
                                                      Text(
                                                          snapshot2.data[
                                                                  "leaderName"] ??
                                                              "Admin",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            });
                      },
                    );
                  }
                });
          }
        }),
      ),
    );
  }
}
