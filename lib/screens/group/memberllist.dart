import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share/share.dart';
import 'package:worldetor/screens/home/drawer.dart';
import 'package:worldetor/services/database.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';
import 'package:worldetor/utils/ourcontener.dart';

class OurGroupMember extends StatefulWidget {
  @override
  _OurGroupMemberState createState() => _OurGroupMemberState();
}

class _OurGroupMemberState extends State<OurGroupMember> {
  _share(BuildContext context) {
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    var groupname = _currentgroup.getCurrentGroup.name;
    String text = _currentgroup.getCurrentGroup.id;
    String subject = "Group joining invitation from $groupname";
    final RenderBox box = context.findRenderObject();
    Share.share(text,
        subject: subject,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
  }

  void _deletedialog(userId, groupId) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Remove",
      desc: "Are you sure? ",
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
            "Remove",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _removemember(userId, groupId);
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

  void _removemember(userId, groupId) async {
    await Firestore.instance.collection("users").document(userId).updateData({
      "listgroup": FieldValue.arrayRemove([groupId]),
    });
    await Firestore.instance.collection("groups").document(groupId).updateData({
      "members": FieldValue.arrayRemove([userId]),
    });
    await Firestore.instance
        .collection("groups")
        .document(groupId)
        .collection("group_member")
        .document(userId)
        .delete();
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("member Removed"), duration: Duration(seconds: 1)));
  }

  void _acceptRequest(
      BuildContext context,
      String groupId,
      String userId,
      String fullname,
      String uniqueid,
      String email,
      String notificationTocken) async {
    String _returnString = await OurDatabase().joinGroup(
        groupId, userId, fullname, email, uniqueid, notificationTocken);

    if (_returnString == "Success") {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Request Accepted"), duration: Duration(seconds: 1)));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Failed something went wrong"),
          duration: Duration(seconds: 1)));
    }
  }

  void _deleteRequest(String groupId, String docId) async {
    await Firestore.instance
        .collection("groups")
        .document(groupId)
        .collection("requests")
        .document(docId)
        .delete();
    // Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text("Request Rejected"), duration: Duration(seconds: 1)));
  }

  int len = 0;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      CurrentUser _currentuser =
          Provider.of<CurrentUser>(context, listen: false);
      return Scaffold(
        appBar: AppBar(
            title: Text(" Members ", style: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
            actions: <Widget>[
              FlatButton(
                minWidth: 5,
                onPressed: () {
                  _share(context);
                },
                child: Row(
                  children: [
                    Text("Invite",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                    Icon(Icons.share, color: Colors.white)
                  ],
                ),
              ),
            ]),
        drawer: OurDrawer(),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection("groups")
                .document(value.getCurrentGroup.id)
                .collection("requests")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
              if (snapshot1.data == null) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                if (snapshot1.data.documents == null) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                          visible: (value.getCurrentGroup.leader ==
                                  _currentuser.getCurrentUser.uid &&
                              snapshot1.data.documents.length > 0),
                          child: Center(child: Text("---Requests---"))),
                      Visibility(
                        visible: (value.getCurrentGroup.leader ==
                                _currentuser.getCurrentUser.uid &&
                            snapshot1.data.documents.length > 0),
                        child: Container(
                          height: 115,
                          child: Row(
                            children: [
                              Flexible(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: snapshot1.data.documents.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Ourcontener(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  snapshot1.data.documents
                                                              .elementAt(index)[
                                                          "fullName"] ??
                                                      "Loading...",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Expanded(
                                              child: Text(
                                                  snapshot1.data.documents
                                                          .elementAt(
                                                              index)["email"] ??
                                                      "Loading...",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  )),
                                            ),
                                            StreamBuilder(
                                                stream: Firestore.instance
                                                    .collection("groups")
                                                    .document(value
                                                        .getCurrentGroup.id)
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<
                                                            DocumentSnapshot>
                                                        memberlistSnapshot) {
                                                  if (memberlistSnapshot.data ==
                                                      null) {
                                                    return Container(
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  } else {
                                                    if (memberlistSnapshot
                                                            .data.data ==
                                                        null) {
                                                      return Container(
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      );
                                                    } else {
                                                      return Center(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Visibility(
                                                              visible: (memberlistSnapshot
                                                                      .data[
                                                                          "members"]
                                                                      .contains(snapshot1
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)["userid"]) ==
                                                                  false),
                                                              child: FlatButton(
                                                                  color: Colors
                                                                      .blue,
                                                                  minWidth: 3,
                                                                  onPressed:
                                                                      () {
                                                                    _acceptRequest(
                                                                      context,
                                                                      value
                                                                          .getCurrentGroup
                                                                          .id,
                                                                      snapshot1
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)["userid"],
                                                                      snapshot1
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)["fullName"],
                                                                      snapshot1
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)["uniqueId"],
                                                                      snapshot1
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)["email"],
                                                                      snapshot1
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)["devicetocken"],
                                                                    );
                                                                    _deleteRequest(
                                                                        value
                                                                            .getCurrentGroup
                                                                            .id,
                                                                        snapshot1
                                                                            .data
                                                                            .documents
                                                                            .elementAt(index)
                                                                            .documentID);
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .check,
                                                                          color:
                                                                              Colors.white),
                                                                      Text(
                                                                          "Accept",
                                                                          style:
                                                                              TextStyle(color: Colors.white)),
                                                                    ],
                                                                  )),
                                                            ),
                                                            SizedBox(
                                                              width: 3,
                                                            ),
                                                            FlatButton(
                                                                color:
                                                                    Colors.red,
                                                                minWidth: 5,
                                                                onPressed: () {
                                                                  _deleteRequest(
                                                                      value
                                                                          .getCurrentGroup
                                                                          .id,
                                                                      snapshot1
                                                                          .data
                                                                          .documents
                                                                          .elementAt(
                                                                              index)
                                                                          .documentID);
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .white),
                                                                    Text(
                                                                        "Reject",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white)),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(height: 1, width: 300, color: Colors.grey),
                      SizedBox(
                        height: 5,
                      ),
                      Center(child: Text("---Members---")),
                      SizedBox(
                        height: 8,
                      ),
                      StreamBuilder(
                          stream: Firestore.instance
                              .collection("groups")
                              .document(value.getCurrentGroup.id)
                              .collection("group_member")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.data == null) {
                              return Container(
                                child: Center(
                                  child: Text("Loading...."),
                                ),
                              );
                            } else {
                              if (snapshot.data.documents == null) {
                                return Container(
                                  child: Center(
                                    child: Text("Loading...."),
                                  ),
                                );
                              } else {
                                return Expanded(
                                  child: ListView.builder(
                                      itemCount:
                                          snapshot.data.documents.length ?? 0,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 10),
                                          child: Slidable(
                                            actionPane:
                                                SlidableDrawerActionPane(),
                                            actionExtentRatio: 0.30,
                                            actions: <Widget>[
                                              IconSlideAction(
                                                  caption: 'Attendance',
                                                  color: Colors.blue,
                                                  icon:
                                                      Icons.markunread_mailbox,
                                                  onTap: () {
                                                    _bottomAttendanceSheet(
                                                        context,
                                                        value
                                                            .getCurrentGroup.id,
                                                        snapshot.data.documents
                                                            .elementAt(index)
                                                            .documentID);
                                                  }),
                                              IconSlideAction(
                                                  caption: 'Points',
                                                  color: Colors.amber,
                                                  icon: Icons.poll,
                                                  onTap: () {
                                                    _bottomPointSheet(
                                                        context,
                                                        value
                                                            .getCurrentGroup.id,
                                                        snapshot.data.documents
                                                            .elementAt(index)
                                                            .documentID);
                                                  }),
                                            ],
                                            secondaryActions: <Widget>[
                                              Visibility(
                                                visible: (value.getCurrentGroup
                                                        .leader ==
                                                    _currentuser
                                                        .getCurrentUser.uid),
                                                child: IconSlideAction(
                                                    caption: 'Remove',
                                                    color: Colors.redAccent,
                                                    icon: Icons.remove_done,
                                                    onTap: () {
                                                      if (value.getCurrentGroup
                                                              .leader ==
                                                          _currentuser
                                                              .getCurrentUser
                                                              .uid) {
                                                        _deletedialog(
                                                            snapshot
                                                                .data.documents
                                                                .elementAt(
                                                                    index)
                                                                .documentID,
                                                            value
                                                                .getCurrentGroup
                                                                .id);
                                                      } else {
                                                        Scaffold.of(context)
                                                            .showSnackBar(new SnackBar(
                                                                content: new Text(
                                                                    "You are not Authorized!")));
                                                      }
                                                    }),
                                              )
                                            ],
                                            child: Material(
                                              child: Ink(
                                                color: Colors.white,
                                                child: Container(
                                                  child: ListTile(
                                                    onTap: () {},
                                                    leading: // CircleAvatar(
                                                        //   backgroundImage: AssetImage(
                                                        //       "lib/assets/google_logo.png"),
                                                        // ),
                                                        Icon(Icons
                                                            .account_circle),
                                                    title: Row(
                                                      children: [
                                                        Text(
                                                            snapshot.data
                                                                        .documents
                                                                        .elementAt(
                                                                            index)[
                                                                    "name"] ??
                                                                "Loading...",
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                        Spacer(),
                                                        Text(
                                                          "Attend: ${snapshot.data.documents.elementAt(index)["attend"]}" ??
                                                              "0",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    subtitle: Row(
                                                      children: [
                                                        Text(
                                                            snapshot.data
                                                                        .documents
                                                                        .elementAt(
                                                                            index)[
                                                                    "email"] ??
                                                                "Loading...",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                        Spacer(),
                                                        Text(
                                                          "Points: ${snapshot.data.documents.elementAt(index)["point"]}" ??
                                                              "0",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                );
                              }
                            }
                          }),
                    ],
                  );
                }
              }
            }),
      );
    });
  }

  void _bottomAttendanceSheet(context, groupid, userid) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder(
              stream: Firestore.instance
                  .collection("groups")
                  .document(groupid)
                  .collection("groupTotalAttendance")
                  .document(userid)
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
                  if (snapshot.data.data == null) {
                    return Container(
                      child: Center(
                        child: Text("Loading...."),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        key: UniqueKey(),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0)),
                        height: MediaQuery.of(context).size.height * .60,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // SizedBox(
                                  //   width: 30,
                                  // ),
                                  Container(
                                      // alignment: Alignment.bottomCenter,
                                      child: Text('Attendance Report',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ))),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                  height: 1, width: 300, color: Colors.grey),
                              Container(
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(snapshot.data["uniqueid"] + " - ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17)),
                                      Expanded(
                                        child: Text(snapshot.data["Name"],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 1, width: 300, color: Colors.grey),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount:
                                        snapshot.data["presentDate"].length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(index.toString() + ".   ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                            Expanded(
                                              child: Text(
                                                  snapshot.data["noticeName"]
                                                      [index],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15)),
                                            ),
                                            Expanded(
                                              child: Text(
                                                  DateFormat.yMMMd("en_US")
                                                      .format(snapshot
                                                          .data["presentDate"]
                                                              [index]
                                                          .toDate()),
                                                  style: TextStyle(fontSize: 15)
                                                  //         +
                                                  // " at  " +
                                                  // DateFormat("H:mm").format(
                                                  //     snapshot
                                                  //         .data["presentDate"]
                                                  //             [index]
                                                  //         .toDate())
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              });
        });
  }

  void _bottomPointSheet(context, groupid, userid) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder(
              stream: Firestore.instance
                  .collection("groups")
                  .document(groupid)
                  .collection("groupTotalAssignment")
                  .document(userid)
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
                  if (snapshot.data.data == null) {
                    return Container(
                      child: Center(
                        child: Text("Loading...."),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        key: UniqueKey(),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0)),
                        height: MediaQuery.of(context).size.height * .60,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // SizedBox(
                                  //   width: 30,
                                  // ),
                                  Container(
                                      // alignment: Alignment.bottomCenter,
                                      child: Text('Assignment Report',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ))),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                  height: 1, width: 300, color: Colors.grey),
                              Container(
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(snapshot.data["uniqueid"] + " - ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17)),
                                      Expanded(
                                        child: Text(snapshot.data["Name"],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  height: 1, width: 300, color: Colors.grey),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount:
                                        snapshot.data["presentDate"].length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                                index.toString() + ".   " ??
                                                    "loading..",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                )),
                                            Expanded(
                                              child: Text(
                                                  snapshot.data["noticeName"]
                                                          [index] ??
                                                      "loading...",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15)),
                                            ),
                                            Text(
                                              DateFormat.yMMMd("en_US").format(
                                                  snapshot.data["presentDate"]
                                                          [index]
                                                      .toDate()),
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            // Spacer(),
                                            SizedBox(width: 20),
                                            Text(
                                                snapshot.data["point"][index]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.red))
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              });
        });
  }
}
