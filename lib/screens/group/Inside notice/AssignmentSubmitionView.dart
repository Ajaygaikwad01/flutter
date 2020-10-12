import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:worldetor/screens/group/Inside%20notice/assignmentBox.dart';
import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

class OurAssignmentSubmitionView extends StatefulWidget {
  @override
  _OurAssignmentSubmitionViewState createState() =>
      _OurAssignmentSubmitionViewState();
}

class _OurAssignmentSubmitionViewState
    extends State<OurAssignmentSubmitionView> {
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

  void _deletedialog(groupId, noticeId, assignmentId) {
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
            _removename(groupId, noticeId, assignmentId);
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

  void _removename(groupId, noticeId, assignmentId) async {
    await Firestore.instance
        .collection("groups")
        .document(groupId)
        .collection("notice")
        .document(noticeId)
        .collection("assignment")
        .document(assignmentId)
        .delete();
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGroup>(
      builder: (BuildContext context, value, Widget child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Assignment Submition"),
          ),
          body: Container(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("groups")
                  .document(value.getCurrentGroup.id)
                  .collection("notice")
                  .document(value.getCurrentGroup.currentNoticeid)
                  .collection("assignment")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data == null) {
                  return Container(
                    child: Center(
                      child: Text("empty"),
                    ),
                  );
                } else {
                  if (snapshot.data.documents == null) {
                    return Container(
                      child: Center(
                        child: Text("empty"),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        // String name = snapshot.data.documents.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 10),
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
                                  _deletedialog(
                                      value.getCurrentGroup.id,
                                      value.getCurrentNotice.id,
                                      snapshot.data.documents
                                          .elementAt(index)
                                          .documentID);
                                },
                              )
                            ],
                            child: Material(
                              child: Ink(
                                color: Colors.white,
                                //  overlayColor: Colors.white,
                                child: Container(
                                  child: ListTile(
                                    onTap: () async {
                                      await Firestore.instance
                                          .collection("groups")
                                          .document(value.getCurrentGroup.id)
                                          .updateData({
                                        "currentAssignmentSenderid": snapshot
                                            .data.documents
                                            .elementAt(index)
                                            .documentID,
                                      });

                                      Widget retval;
                                      retval = ChangeNotifierProvider(
                                        create: (context) => CurrentGroup(),
                                        child: OurAssignmentBox(),
                                      );
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => retval,
                                      ));
                                    },
                                    title: Row(
                                      children: [
                                        Text(snapshot.data.documents
                                                .elementAt(index)["userName"] ??
                                            "Loading..."),
                                        Spacer(),
                                        IconButton(
                                            splashColor: Colors.grey,
                                            icon: Icon(Icons.check_box_sharp,
                                                color: Colors.blueAccent),
                                            onPressed: () async {
                                              int noticepoint =
                                                  value.getCurrentNotice.point;
                                              DocumentSnapshot docref =
                                                  await Firestore.instance
                                                      .collection("groups")
                                                      .document(value
                                                          .getCurrentGroup.id)
                                                      .collection(
                                                          "group_member")
                                                      .document(snapshot
                                                          .data.documents
                                                          .elementAt(index)
                                                          .documentID)
                                                      .get();
                                              var currntpoint =
                                                  docref.data["point"];
                                              int totalpoint =
                                                  currntpoint + noticepoint;
                                              print(totalpoint);
                                              await Firestore.instance
                                                  .collection("groups")
                                                  .document(
                                                      value.getCurrentGroup.id)
                                                  .collection("group_member")
                                                  .document(snapshot
                                                      .data.documents
                                                      .elementAt(index)
                                                      .documentID)
                                                  .updateData(
                                                      {"point": totalpoint});
                                              Scaffold.of(context).showSnackBar(
                                                  new SnackBar(
                                                      content: new Text(
                                                          "Assignment mark Added")));
                                            }),
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
              },
            ),
          ),
        );
      },
    );
  }
}
