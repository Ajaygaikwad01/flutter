import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:worldetor/screens/home/drawer.dart';

import 'package:worldetor/state/currentgroup.dart';
import 'package:worldetor/state/currentuser.dart';

import 'package:worldetor/widgets/HomeNavigator.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGroup>(
        builder: (BuildContext context, value, Widget child) {
      return Scaffold(
        appBar: AppBar(
            title: Text(value.getCurrentGroup.name ?? " loding...."),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeNavigator()),
                      (route) => false);
                },
              ),
              IconButton(
                  icon: Icon(Icons.share),
                  tooltip: "invite",
                  onPressed: () {
                    _share(context);
                  }),
            ]),
        drawer: OurDrawer(),
        body: Container(
            child: // StreamBuilder(
                //   stream: Firestore.instance
                //       .collection("groups")
                //       .document(value.getCurrentGroup.id)
                //       .snapshots(),
                //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                //     if (snapshot.data == null) {
                //       return Container(
                //         child: Center(
                //           child: Text("empty"),
                //         ),
                //       );
                //     } else {
                //   return
                ListView.builder(
          itemCount: value.getCurrentGroup.members.length,
          itemBuilder: (BuildContext context, int index) {
            return StreamBuilder(
                stream: Firestore.instance
                    .collection("users")
                    .document(value.getCurrentGroup.members[index])
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
                    return ListTile(
                      leading: // CircleAvatar(
                          //   backgroundImage: AssetImage(
                          //       "lib/assets/google_logo.png"),
                          // ),
                          Icon(Icons.account_circle),
                      title: Text(snapshot.data["fullName"]),
                      subtitle: Text(snapshot.data["email"]),
                    );
                  }
                });
          },
        )
            // }
            //   },
            // ),
            ),
      );
    });
  }
}
