import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurAttendanceView extends StatefulWidget {
  @override
  _OurAttendanceViewState createState() => _OurAttendanceViewState();
}

class _OurAttendanceViewState extends State<OurAttendanceView> {
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

  void _deletedialog(groupId, noticeId, name, nameid) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Remove",
      desc: "Are you sure?",
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
            _removename(groupId, noticeId, name, nameid);
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

  void _removename(groupId, noticeId, name, nameid) async {
    await Firestore.instance
        .collection("groups")
        .document(groupId)
        .collection("notice")
        .document(noticeId)
        .updateData({
      "attendynames": FieldValue.arrayRemove([name]),
      "attendyid": FieldValue.arrayRemove([nameid]),
    });
  }

  void attendbutton(groupid, indexval) async {
    DateTime time = DateTime.now();
    String currentTime = DateFormat.yMMMMd("en_US").format(time);

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    int noticepoint = 1;
    DocumentSnapshot docref = await Firestore.instance
        .collection("groups")
        .document(groupid)
        .collection("group_member")
        .document(indexval)
        .get();
    var currntpoint = docref.data["attend"];
    int totalpoint = currntpoint + noticepoint;

    print(totalpoint);
    await Firestore.instance
        .collection("groups")
        .document(groupid)
        .collection("group_member")
        .document(indexval)
        .updateData({"attend": totalpoint});
    // await OurDatabase().groupTotalAttendance(
    //     groupid, _currentuser.getCurrentUser.uniqueId, currentTime);
    await Firestore.instance
        .collection("groups")
        .document(groupid)
        .collection("groupTotalAttendance")
        .document(_currentuser.getCurrentUser.uniqueId)
        .updateData({
      //  'id': _docref.documentID,
      currentTime: "present",
    });
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGroup>(
      builder: (BuildContext context, value, Widget child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Attendees List"),
          ),
          body: Container(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection("groups")
                    .document(value.getCurrentGroup.id)
                    .collection("notice")
                    .document(value.getCurrentGroup.currentNoticeid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      child: Center(
                        child: Text("empty"),
                      ),
                    );
                  } else {
                    if (snapshot.data.data == null) {
                      return Container(
                        child: Center(
                          child: Text("empty"),
                        ),
                      );
                    } else {
                      if (snapshot.data["attendynames"].length != null) {
                        return ListView.builder(
                          itemCount: snapshot.data["attendynames"].length,
                          itemBuilder: (BuildContext context, int index) {
                            String name = snapshot.data["attendynames"][index];
                            String nameid = snapshot.data["attendyid"][index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 10),
                              child: Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.30,
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    caption: 'Remove',
                                    color: Colors.redAccent,
                                    icon: Icons.delete,
                                    onTap: () {
                                      setState(() {
                                        loading = !loading;
                                      });
                                      _deletedialog(
                                          value.getCurrentGroup.id,
                                          value.getCurrentNotice.id,
                                          name,
                                          nameid);
                                      // _deletedialog(value.getCurrentUser.uid,
                                      //     snapshot2.data.documentID);
                                    },
                                  )
                                ],
                                child: Material(
                                  child: Ink(
                                    color: Colors.white,
                                    child: Container(
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Text(snapshot.data["attendynames"]
                                                    [index] ??
                                                "Loading "),
                                            Spacer(),
                                            IconButton(
                                                splashColor: Colors.grey,
                                                icon: Icon(
                                                    Icons.check_box_sharp,
                                                    color: Colors.blueAccent),
                                                onPressed: () async {
                                                  attendbutton(
                                                      value.getCurrentGroup.id,
                                                      snapshot.data["attendyid"]
                                                          [index]);

                                                  _removename(
                                                      value.getCurrentGroup.id,
                                                      value.getCurrentNotice.id,
                                                      name,
                                                      nameid);
                                                  // await Firestore.instance
                                                  //     .collection("groups")
                                                  //     .document(value
                                                  //         .getCurrentGroup.id)
                                                  //     .collection("notice")
                                                  //     .document(value
                                                  //         .getCurrentNotice.id)
                                                  //     .updateData({
                                                  //   "attendynames":
                                                  //       FieldValue.arrayRemove(
                                                  //           [name]),
                                                  //   "attendyid":
                                                  //       FieldValue.arrayRemove(
                                                  //           [nameid]),
                                                  // });
                                                  Scaffold.of(context)
                                                      .showSnackBar(new SnackBar(
                                                          content: new Text(
                                                              "Attendance marked")));
                                                }),
                                            // IconButton(
                                            //   splashColor: Colors.grey,
                                            //   icon: Icon(Icons.delete),
                                            //   onPressed: () async {
                                            //     await Firestore.instance
                                            //         .collection("groups")
                                            //         .document(value
                                            //             .getCurrentGroup.id)
                                            //         .collection("notice")
                                            //         .document(value
                                            //             .getCurrentNotice.id)
                                            //         .updateData({
                                            //       "attendynames":
                                            //           FieldValue.arrayRemove(
                                            //               [name]),
                                            //       "attendyid":
                                            //           FieldValue.arrayRemove(
                                            //               [nameid]),
                                            //     });
                                            //   },
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  }
                }),
          ),
        );
      },
    );
  }
}
