import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:worldetor/state/currentgroup.dart';

import 'package:worldetor/state/currentuser.dart';

class OurLiveDrawer extends StatefulWidget {
  @override
  _OurLiveDrawerState createState() => _OurLiveDrawerState();
}

class _OurLiveDrawerState extends State<OurLiveDrawer> {
  @override
  void initState() {
    super.initState();

    CurrentUser _currentuser = Provider.of<CurrentUser>(context, listen: false);
    CurrentGroup _currentgroup =
        Provider.of<CurrentGroup>(context, listen: false);
    _currentgroup.updateSteteFromDatabase(
        _currentuser.getCurrentUser.groupid, _currentuser.getCurrentUser.uid);
    // _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<CurrentGroup>(
          builder: (BuildContext context, value, Widget child) {
        return StreamBuilder(
            stream: Firestore.instance
                .collection("groups")
                .document(value.getCurrentGroup.id)
                .collection("notice")
                .document(value.getCurrentNotice.id)
                .collection("joinmembers")
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Text("empty"),
                );
              } else {
                return Column(
                  children: <Widget>[
                    SizedBox(height: 8),
                    ListTile(
                      title: Row(
                        children: [
                          Text(
                            "Members",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Spacer(),
                          Icon(Icons.remove_red_eye, color: Colors.white),
                          Text("(${snapshot.data.documents.length})",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                      tileColor: Color(0xFF21BFBD),
                    ),
                    Container(
                      child: Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(snapshot.data.documents
                                        .elementAt(index)["username"] ??
                                    "Loading.."),
                              );
                            }),
                      ),
                    ),
                  ],
                );
              }
            });
      }),
    );
  }
}
