import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                    return ListView.builder(
                      itemCount: snapshot.data["attendynames"].length,
                      itemBuilder: (BuildContext context, int index) {
                        String name = snapshot.data["attendynames"][index];
                        String nameid = snapshot.data["attendyid"][index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 10),
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
                                          icon: Icon(Icons.check_box_sharp,
                                              color: Colors.blueAccent),
                                          onPressed: () async {
                                            int noticepoint = 1;
                                            DocumentSnapshot docref =
                                                await Firestore.instance
                                                    .collection("groups")
                                                    .document(value
                                                        .getCurrentGroup.id)
                                                    .collection("group_member")
                                                    .document(snapshot
                                                            .data["attendyid"]
                                                        [index])
                                                    .get();
                                            var currntpoint =
                                                docref.data["attend"];
                                            int totalpoint =
                                                currntpoint + noticepoint;
                                            print(totalpoint);
                                            await Firestore.instance
                                                .collection("groups")
                                                .document(
                                                    value.getCurrentGroup.id)
                                                .collection("group_member")
                                                .document(snapshot
                                                    .data["attendyid"][index])
                                                .updateData(
                                                    {"attend": totalpoint});

                                            Scaffold.of(context).showSnackBar(
                                                new SnackBar(
                                                    content: new Text(
                                                        "Attendance saved In database")));
                                          }),
                                      IconButton(
                                          splashColor: Colors.grey,
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            await Firestore.instance
                                                .collection("groups")
                                                .document(
                                                    value.getCurrentGroup.id)
                                                .collection("notice")
                                                .document(
                                                    value.getCurrentNotice.id)
                                                .updateData({
                                              "attendynames":
                                                  FieldValue.arrayRemove(
                                                      [name]),
                                              "attendyid":
                                                  FieldValue.arrayRemove(
                                                      [nameid]),
                                            });
                                          })
                                    ],
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
