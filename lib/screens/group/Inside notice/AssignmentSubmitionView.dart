import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(snapshot.data.documents
                                          .elementAt(index)["userName"] ??
                                      "Loading..."),
                                  Spacer(),
                                  IconButton(
                                      splashColor: Colors.grey,
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await Firestore.instance
                                            .collection("groups")
                                            .document(value.getCurrentGroup.id)
                                            .collection("notice")
                                            .document(value.getCurrentNotice.id)
                                            .collection("assignment")
                                            .document(snapshot.data.documents
                                                .elementAt(index)
                                                .documentID)
                                            .delete();
                                      })
                                ],
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
